module single_cycle_core (
   input clk,rst,
   input [31:0] instr,
   input [31:0]read_data,
   output [31:0] PC,
   output [31:0] Alu_result,
   output [31:0] Write_data,
   output memwrite
);
wire zero,alu_src,pc_src,regWrite,jump;
wire [1:0] result_src,Immgen_src;
wire [3:0] aluControl;
control_unit cu(
    .opcode(instr[6:0]),
    .funct3(instr[2:0]),
    .funct7_of_bit5(instr[30]),
    .zero(zero),
    .result_src(result_src),
    .alu_src(alu_src),
    .pc_src(pc_src),
    .regWrite(regWrite),
    .memwrite(memwrite),
    .jump(jump),
    .Immgen_src(Immgen_src),
    .aluControl(aluControl)
);
data_path dp(
    .clk(clk),
    .rst(rst),
    .Regwrite(regWrite),
    .Pc_Src(pc_src),
    .alu_src(alu_src),
    .imm_src(Immgen_src),
    .result_src(result_src),
    .Alu_control(aluControl),
    .instr(instr),
    .read_data(read_data),
    .zero(zero),
    .PC(PC),
    .Alu_result(Alu_result),
    .Write_data(Write_data)
);
endmodule