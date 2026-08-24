module reg_mem_block(
    input clk,  
    input write_en,
    input [4:0] read_address1, read_address2,
    input [4:0] write_address,
    input [31:0] write_data,
    output  [31:0] read_data1,read_data2
);
reg [31:0] regfile [0:31];
always @ (posedge clk) begin
    if (write_en) begin
     regfile[write_address] <= write_data;
    end
end
assign read_data1 = (read_address1 != 0 )? regfile[read_address1] : 0;
assign read_data2 = (read_address2 != 0 )? regfile[read_address2] : 0;
endmodule
