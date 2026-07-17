
`timescale 1ns / 1ps
module full_adder_fixed2 #(
    parameter DELAY_SUM  = 1,
    parameter DELAY_COUT = 1
)(
    input  a, b, cin,
    output sum, cout
);
    assign #(DELAY_SUM)  sum  = a ^ b ^ cin;
    assign #(DELAY_COUT) cout = (a & b) | (b & cin) | (a & cin);
endmodule