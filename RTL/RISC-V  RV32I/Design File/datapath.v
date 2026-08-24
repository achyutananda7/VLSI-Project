module data_path(
    input clk,rst,
    input Regwrite,
    input Pc_Src,
    input alu_src,
    input [1:0] imm_src,
    input [1:0]result_src,
    input [3:0] Alu_control,
    input [31:0] instr,
    input [31:0]read_data,
    output zero,
    output [31:0] PC,
    output [31:0] Alu_result,
    output [31:0] Write_data
);
    
wire  [31:0] PC4,Pc_Target,PCNext,imm_gen;
wire [31:0] Src_A,Src_B;
wire [31:0]result;
pc pc(
    .clk(clk),
    .rst(rst),
    .PCNext(PCNext),
    .PC(PC)
);

pc4_adder pc4(
    .PC(PC),
    .PC4(PC4)
);

Pc_Target PT(
    .PC(PC),
    .ImmExt(imm_gen),
    .Pc_Target(Pc_Target)
);

PC_Mux pcmux(
    .PC4(PC4),
    .Pc_Target(Pc_Target),
    .PCSrc(Pc_Src),
    .PCNext(PCNext)
);

reg_mem_block registermem (
    .clk(clk),
    .write_en(Regwrite),
    .read_address1(instr[19:15]),
    .read_address2(instr[24:20]),
    .write_address(instr[11:7]),
    .write_data(result),
    .read_data1(Src_A),
    .read_data2(Write_data)
);

imm_gen immediate_gen (
    .instr(instr[31:7]),
    .imm_src(imm_src),
    .imm_gen(imm_gen)
);

alu ALu(
    .A(Src_A),
    .B(Src_B),
    .Alu_control(Alu_control),
    .Alu_result(Alu_result),
    .zero(zero)
);

alu_mux alumux(
    .alu_src(alu_src),
    .ImmExt(imm_gen),
    .Read_Data2(Write_data),
    .AluB_input(Src_B)
);

result_mux resultmux(
    .read_data(read_data),
    .Alu_result(Alu_result),
    .result_src(result_src),
    .pc4(PC4),
    .result(result)
);

endmodule