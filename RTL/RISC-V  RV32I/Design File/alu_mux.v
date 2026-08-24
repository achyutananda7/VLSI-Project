module alu_mux(
    input alu_src,
    input [31:0] ImmExt,
    input [31:0]Read_Data2,
    output [31:0]AluB_input
);
assign AluB_input = alu_src ? ImmExt : Read_Data2;
endmodule