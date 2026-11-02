module mini_cpu (
    input clk,
    input rst,

    input [7:0] instruction,

    output [7:0] result
);

wire [1:0] opcode;
wire [1:0] rd;
wire [1:0] rs1;
wire [1:0] rs2;

wire [7:0] data1;
wire [7:0] data2;

wire [7:0] alu_result;

wire write_en;
wire [1:0] alu_op;

assign opcode = instruction[7:6];
assign rd     = instruction[5:4];
assign rs1    = instruction[3:2];
assign rs2    = instruction[1:0];

control_unit CU (
    .opcode(opcode),
    .write_en(write_en),
    .alu_op(alu_op)
);

register_file RF (
    .clk(clk),
    .rst(rst),
    .write_en(write_en),
    .rd(rd),
    .rs1(rs1),
    .rs2(rs2),
    .write_data(alu_result),
    .data1(data1),
    .data2(data2)
);

alu ALU (
    .a(data1),
    .b(data2),
    .op(alu_op),
    .result(alu_result)
);

assign result = alu_result;

endmodule