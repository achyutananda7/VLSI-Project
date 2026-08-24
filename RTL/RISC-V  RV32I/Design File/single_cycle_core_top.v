module single_cycle_core_top (
    input clk,rst,
    output [31:0] Write_data,
    output [31:0] Alu_result,
    output memwrite
);
wire [31:0] PC,instr,read_data;

single_cycle_core s_core(
    .clk(clk),
    .rst(rst),
    .instr(instr),
    .read_data(read_data),
    .PC(PC),
    .Alu_result(Alu_result),
    .Write_data(Write_data),
    .memwrite(memwrite)
);

instruction_mem im(
    .Read_address(PC),
    .Data(instr)
);

data_mem data_memory(
    .A(Alu_result),
    .Data_write(Write_data),
    .we(memwrite),
    .clk(clk),
    .Read_data(read_data)
);
endmodule