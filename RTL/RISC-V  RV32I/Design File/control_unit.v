module control_unit (
input [6:0] opcode,
input [2:0] funct3,
input funct7_of_bit5,
input zero,
output [1:0] result_src,
output alu_src,
output pc_src,
output regWrite,
output memwrite,
output jump,
output [1:0] Immgen_src,
output [3:0] aluControl
);
wire [1:0] Alu_op;
wire branch;
main_decoder d1(
    .opcode(opcode),
    .Regwrite(regWrite),
    .alu_src(alu_src),
    .memwrite(memwrite),
    .branch(branch),
    .jump(jump),
    .Immgen_src(Immgen_src),
    .result_src(result_src),
    .Alu_op(Alu_op)
);
Alu_decoder d2(
    .opcode(opcode),
    .funct3(funct3),
    .funct7_of_bit5(funct7_of_bit5),
    .Alu_opcode(Alu_op),
    .Alu_control(aluControl)
);
assign pc_src = branch & zero| jump;
endmodule