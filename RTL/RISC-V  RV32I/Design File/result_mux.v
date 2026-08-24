module result_mux(
    input [31:0] read_data,
    input [31:0] Alu_result,
    input [1:0]  result_src,
    input [31:0] pc4,
    output reg [31:0] result
);
always @(*) begin
    case(result_src)
    2'b00 : result = Alu_result;
    2'b01 : result = read_data;
    2'b10 : result = pc4;
    2'b11 : result = pc4;
    default : result = 32'b0;
    endcase
end
endmodule