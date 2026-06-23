module Core_Logic (
    input wire A,
    input wire B,
    output wire Y
);
    assign Y = A | B;
endmodule