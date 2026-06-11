module baud_generator (
    input clk,
    input rst,
    output reg tick
);

reg [8:0] count;
always @(posedge clk or negedge rst) begin
    if(!rst)begin
        count <= 0;
        tick <= 0;
    end
    else if (count == 9'd324)begin
        count <=0;
        tick <= 1'b1;
    end
    else begin
    tick <= 1'b0;
    count <= count + 1;
    end
    
end
endmodule