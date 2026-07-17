module digital_twin_top_selfcorrect(
    input        clk,
    input        reset,
    input  [3:0] A, B,
    input        Cin,
    input  [1:0] age_stage,

    output [7:0] mismatch_count,
    output       alarm,
    output [3:0] bit_fault_count0,
    output [3:0] bit_fault_count1,
    output [3:0] bit_fault_count2,
    output [3:0] bit_fault_count3,
    output       cout_fault,
    output [1:0] freq_scale,
    output       action_taken,
    output [1:0] health_zone,

    // Stage 6 new outputs
    output [6:0] health_score,
    output [7:0] rul_cycles,
    output       end_of_life
);

    wire [3:0] Sum_nominal, Sum_aged;
    wire       Cout_nominal, Cout_aged;
    wire       mismatch_flag;

    // Cycle counter
    reg [7:0] cycle_count;
    always @(posedge clk or posedge reset) begin
        if (reset) cycle_count <= 0;
        else       cycle_count <= cycle_count + 1;
    end

    // Twin adder
    digital_twin_progressive2 dut (
        .A(A),.B(B),.Cin(Cin),
        .age_stage(age_stage),
        .Sum_nominal(Sum_nominal),
        .Sum_aged(Sum_aged),
        .Cout_nominal(Cout_nominal),
        .Cout_aged(Cout_aged),
        .mismatch_flag(mismatch_flag)
    );

    // Self correcting monitor
    twin_monitor_selfcorrect monitor (
        .clk(clk),.reset(reset),
        .Sum_nominal(Sum_nominal),
        .Sum_aged(Sum_aged),
        .Cout_nominal(Cout_nominal),
        .Cout_aged(Cout_aged),
        .mismatch_count(mismatch_count),
        .alarm(alarm),
        .bit_fault_count0(bit_fault_count0),
        .bit_fault_count1(bit_fault_count1),
        .bit_fault_count2(bit_fault_count2),
        .bit_fault_count3(bit_fault_count3),
        .cout_fault(cout_fault),
        .freq_scale(freq_scale),
        .action_taken(action_taken),
        .health_zone(health_zone)
    );

    // Health and RUL calculator
    health_rul_calculator health_calc (
        .clk(clk),.reset(reset),
        .mismatch_count(mismatch_count),
        .cycle_count(cycle_count),
        .health_score(health_score),
        .rul_cycles(rul_cycles),
        .end_of_life(end_of_life)
    );

endmodule
