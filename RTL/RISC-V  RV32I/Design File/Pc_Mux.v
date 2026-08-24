module PC_Mux (
    input [31:0] PC4,
    input [31:0] Pc_Target,
    input PCSrc,
    output [31:0] PCNext
);
assign PCNext = PCSrc ? Pc_Target : PC4;
endmodule