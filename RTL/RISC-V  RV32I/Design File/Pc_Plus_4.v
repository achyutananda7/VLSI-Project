module pc4_adder (
    input [31:0] PC,
    output [31:0] PC4
);
    assign PC4 = PC + 32'd4;
endmodule
