module ripple_adder_fixed2 #(
    // Sum delays per stage (fa0 to fa3)
    parameter DS0 = 1, parameter DS1 = 1,
    parameter DS2 = 1, parameter DS3 = 1,
    // Cout delays per stage
    parameter DC0 = 1, parameter DC1 = 1,
    parameter DC2 = 1, parameter DC3 = 1
)(
    input  [3:0] A, B,
    input        Cin,
    output [3:0] Sum,
    output       Cout
);
    wire c0, c1, c2;

    full_adder_fixed2 #(.DELAY_SUM(DS0),.DELAY_COUT(DC0))
        fa0(.a(A[0]),.b(B[0]),.cin(Cin), .sum(Sum[0]),.cout(c0));

    full_adder_fixed2 #(.DELAY_SUM(DS1),.DELAY_COUT(DC1))
        fa1(.a(A[1]),.b(B[1]),.cin(c0),  .sum(Sum[1]),.cout(c1));

    full_adder_fixed2 #(.DELAY_SUM(DS2),.DELAY_COUT(DC2))
        fa2(.a(A[2]),.b(B[2]),.cin(c1),  .sum(Sum[2]),.cout(c2));

    full_adder_fixed2 #(.DELAY_SUM(DS3),.DELAY_COUT(DC3))
        fa3(.a(A[3]),.b(B[3]),.cin(c2),  .sum(Sum[3]),.cout(Cout));

endmodule