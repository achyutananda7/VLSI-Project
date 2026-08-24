module pc (
    output reg [31:0] PC,
    input clk,rst,
    input [31:0] PCNext
);
always @ (posedge clk or posedge rst) begin
    if (rst) begin
        PC <= 32'd0;
    end
    else begin
        PC <= PCNext;
    end
end
endmodule









