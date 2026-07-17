module digital_twin_progressive2(
    input  [3:0] A, B,
    input        Cin,
    input  [1:0] age_stage,
    output [3:0] Sum_nominal,
    output [3:0] Sum_aged,
    output       Cout_nominal,
    output       Cout_aged,
    output       mismatch_flag
);

    // --- Nominal adder ---
    ripple_adder_fixed2 #(
        .DS0(1),.DS1(1),.DS2(1),.DS3(1),
        .DC0(1),.DC1(1),.DC2(1),.DC3(1)
    ) nominal (
        .A(A),.B(B),.Cin(Cin),
        .Sum(Sum_nominal),.Cout(Cout_nominal)
    );

    // --- Fresh twin (age=0): very small delays ---
    wire [3:0] Sum_fresh; wire Cout_fresh;
    ripple_adder_fixed2 #(
        .DS0(2),.DS1(2),.DS2(2),.DS3(2),
        .DC0(1),.DC1(1),.DC2(1),.DC3(1)
    ) twin_fresh (
        .A(A),.B(B),.Cin(Cin),
        .Sum(Sum_fresh),.Cout(Cout_fresh)
    );

    // --- Mild twin (age=1): non-uniform delays ---
    // fa0: sum=3, fa1: sum=5, fa2: sum=7, fa3: sum=9
    wire [3:0] Sum_mild; wire Cout_mild;
    ripple_adder_fixed2 #(
        .DS0(3),.DS1(5),.DS2(7),.DS3(9),
        .DC0(2),.DC1(3),.DC2(4),.DC3(5)
    ) twin_mild (
        .A(A),.B(B),.Cin(Cin),
        .Sum(Sum_mild),.Cout(Cout_mild)
    );

    // --- Heavy twin (age=2): non-uniform delays ---
    // fa0: sum=5, fa1: sum=8, fa2: sum=11, fa3: sum=14
    wire [3:0] Sum_heavy; wire Cout_heavy;
    ripple_adder_fixed2 #(
        .DS0(5),.DS1(8),.DS2(11),.DS3(14),
        .DC0(3),.DC1(5), .DC2(7), .DC3(9)
    ) twin_heavy (
        .A(A),.B(B),.Cin(Cin),
        .Sum(Sum_heavy),.Cout(Cout_heavy)
    );

    // --- MUX: select aged output based on age_stage ---
    assign Sum_aged  = (age_stage == 2'd0) ? Sum_fresh  :
                       (age_stage == 2'd1) ? Sum_mild   :
                                             Sum_heavy;

    assign Cout_aged = (age_stage == 2'd0) ? Cout_fresh :
                       (age_stage == 2'd1) ? Cout_mild  :
                                             Cout_heavy;

    // --- Mismatch flag ---
    assign mismatch_flag = (Sum_nominal !== Sum_aged) |
                           (Cout_nominal !== Cout_aged);

endmodule