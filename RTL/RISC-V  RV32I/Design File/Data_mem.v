module data_mem (
    input [31:0] A,
    input [31:0] Data_write,
    input we,
    input clk,
    output [31:0] Read_data
);
reg [31:0] mem[63:0];
assign Read_data = mem[A[31:2]];
always @ (posedge clk) begin
    if (we) begin
        mem[A[31:2]] <= Data_write;
    end
end
endmodule