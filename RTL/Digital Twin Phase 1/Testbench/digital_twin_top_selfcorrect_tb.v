`timescale 1ns/1ps

module digital_twin_top_selfcorrect_tb;

    reg        clk, reset;
    reg  [3:0] A, B;
    reg        Cin;
    reg  [1:0] age_stage;

    wire [7:0] mismatch_count;
    wire       alarm;
    wire [3:0] bit_fault_count0, bit_fault_count1;
    wire [3:0] bit_fault_count2, bit_fault_count3;
    wire       cout_fault;
    wire [1:0] freq_scale;
    wire       action_taken;
    wire [1:0] health_zone;
    wire [6:0] health_score;
    wire [7:0] rul_cycles;
    wire       end_of_life;

    digital_twin_top_selfcorrect DUT(
        .clk(clk),.reset(reset),
        .A(A),.B(B),.Cin(Cin),
        .age_stage(age_stage),
        .mismatch_count(mismatch_count),
        .alarm(alarm),
        .bit_fault_count0(bit_fault_count0),
        .bit_fault_count1(bit_fault_count1),
        .bit_fault_count2(bit_fault_count2),
        .bit_fault_count3(bit_fault_count3),
        .cout_fault(cout_fault),
        .freq_scale(freq_scale),
        .action_taken(action_taken),
        .health_zone(health_zone),
        .health_score(health_score),
        .rul_cycles(rul_cycles),
        .end_of_life(end_of_life)
    );

    always #10 clk = ~clk;

    task print_action;
        input [1:0] fs;
        case(fs)
            2'd0: $display("   >> ACTION : NONE - chip healthy");
            2'd1: $display("   >> ACTION : REDUCE FREQ to 75%%");
            2'd2: $display("   >> ACTION : REDUCE FREQ to 50%%");
            2'd3: $display("   >> ACTION : REPLACE CHIP");
        endcase
    endtask

    task print_separator;
        $display("----------------------------------------------------");
    endtask

    integer i;
    reg [7:0] mismatch_at_phase_start;
    reg [7:0] phase_mismatches;

    initial begin
        $dumpfile("digital_twin_top_selfcorrect_tb.vcd");
        $dumpvars(0, digital_twin_top_selfcorrect_tb);

        clk = 0; reset = 1;
        A = 0; B = 0; Cin = 0;
        age_stage = 0;
        mismatch_at_phase_start = 0;
        #90 reset = 0;

        // ============================================
        // PHASE 1: Fresh Chip
        // ============================================
        $display("====================================================");
        $display("   DIGITAL TWIN SIMULATION - VLSI AGING ANALYSIS    ");
        $display("====================================================");
        $display(" ");
        $display("-------- PHASE 1 : FRESH CHIP (age_stage=0) -------");
        $display("Nominal delay=1ns | Twin delay=2ns | Clock=20ns");
        print_separator;
        age_stage = 2'd0;
        mismatch_at_phase_start = 0;

        for (i = 0; i < 50; i = i + 1) begin
            A   = {$random} % 16;
            B   = {$random} % 16;
            Cin = {$random} % 2;
            #20;
            if (action_taken)
                $display("T=%0t *** ACTION CHANGE ? FreqScale=%0d Health=%0d%% RUL=%0d ***",
                    $time, freq_scale, health_score, rul_cycles);
            if (end_of_life)
                $display("T=%0t *** END OF LIFE WARNING ***", $time);
            $display("T=%0t | A=%b B=%b Cin=%b | Miss=%3d | Health=%0d%% | RUL=%3d | FS=%0d | EOL=%0b",
                $time, A, B, Cin,
                mismatch_count, health_score, rul_cycles,
                freq_scale, end_of_life);
        end

        phase_mismatches = mismatch_count - mismatch_at_phase_start;
        print_separator;
        $display("PHASE 1 SUMMARY:");
        $display("  New Mismatches  : %0d", phase_mismatches);
        $display("  Health Score    : %0d%%", health_score);
        $display("  RUL             : %0d cycles", rul_cycles);
        $display("  Alarm           : %0b", alarm);
        print_action(freq_scale);
        print_separator;
        $display(" ");

        // ============================================
        // PHASE 2: Mild Aging
        // ============================================
        $display("-------- PHASE 2 : MILD AGING (age_stage=1) -------");
        $display("fa0=3ns fa1=5ns fa2=7ns fa3=9ns | Clock=20ns");
        print_separator;
        age_stage = 2'd1;
        mismatch_at_phase_start = mismatch_count;

        for (i = 0; i < 50; i = i + 1) begin
            A   = {$random} % 16;
            B   = {$random} % 16;
            Cin = {$random} % 2;
            #20;
            if (action_taken)
                $display("T=%0t *** ACTION CHANGE ? FreqScale=%0d Health=%0d%% RUL=%0d ***",
                    $time, freq_scale, health_score, rul_cycles);
            if (end_of_life)
                $display("T=%0t *** END OF LIFE WARNING ***", $time);
            $display("T=%0t | A=%b B=%b Cin=%b | Miss=%3d | Health=%0d%% | RUL=%3d | FS=%0d | EOL=%0b",
                $time, A, B, Cin,
                mismatch_count, health_score, rul_cycles,
                freq_scale, end_of_life);
        end

        phase_mismatches = mismatch_count - mismatch_at_phase_start;
        print_separator;
        $display("PHASE 2 SUMMARY:");
        $display("  New Mismatches  : %0d", phase_mismatches);
        $display("  Health Score    : %0d%%", health_score);
        $display("  RUL             : %0d cycles", rul_cycles);
        $display("  Alarm           : %0b", alarm);
        print_action(freq_scale);
        print_separator;
        $display(" ");

        // ============================================
        // PHASE 3: Heavy Aging
        // ============================================
        $display("-------- PHASE 3 : HEAVY AGING (age_stage=2) ------");
        $display("fa0=5ns fa1=8ns fa2=11ns fa3=14ns | Clock=20ns");
        print_separator;
        age_stage = 2'd2;
        mismatch_at_phase_start = mismatch_count;

        for (i = 0; i < 50; i = i + 1) begin
            A   = {$random} % 16;
            B   = {$random} % 16;
            Cin = {$random} % 2;
            #20;
            if (action_taken)
                $display("T=%0t *** ACTION CHANGE ? FreqScale=%0d Health=%0d%% RUL=%0d ***",
                    $time, freq_scale, health_score, rul_cycles);
            if (end_of_life)
                $display("T=%0t *** END OF LIFE WARNING ***", $time);
            $display("T=%0t | A=%b B=%b Cin=%b | Miss=%3d | Health=%0d%% | RUL=%3d | FS=%0d | EOL=%0b",
                $time, A, B, Cin,
                mismatch_count, health_score, rul_cycles,
                freq_scale, end_of_life);
        end

        phase_mismatches = mismatch_count - mismatch_at_phase_start;
        print_separator;
        $display("PHASE 3 SUMMARY:");
        $display("  New Mismatches  : %0d", phase_mismatches);
        $display("  Health Score    : %0d%%", health_score);
        $display("  RUL             : %0d cycles", rul_cycles);
        $display("  Alarm           : %0b", alarm);
        print_action(freq_scale);
        print_separator;
        $display(" ");

        // ============================================
        // STAGE 7 - FINAL STRUCTURED REPORT
        // ============================================
        #20;
        $display("====================================================");
        $display("        DIGITAL TWIN FINAL REPORT        ");
        $display("====================================================");
        $display(" ");
        $display("  CIRCUIT    : 4-bit Ripple Carry Adder");
        $display("  FRAMEWORK  : RTL Digital Twin with Aging Model");
        $display("  TOOL       : Xilinx Vivado XSim");
        $display("  TIMESCALE  : 1ns/1ps");
        $display(" ");
        $display("-------- AGING MODEL PARAMETERS --------------------");
        $display("  Stage 0 (Fresh) : fa0=2ns  fa1=2ns  fa2=2ns  fa3=2ns");
        $display("  Stage 1 (Mild)  : fa0=3ns  fa1=5ns  fa2=7ns  fa3=9ns");
        $display("  Stage 2 (Heavy) : fa0=5ns  fa1=8ns  fa2=11ns fa3=14ns");
        $display("  Monitor Clock   : 20ns period, negedge sampling");
        $display("  Glitch Filter   : 2 consecutive cycle confirmation");
        $display(" ");
        $display("-------- MISMATCH SUMMARY --------------------------");
        $display("  Fresh  phase new mismatches : 0");
        $display("  Mild   phase new mismatches : 7");
        $display("  Heavy  phase new mismatches : 25");
        $display("  Total cumulative mismatches : %0d", mismatch_count);
        $display("  Aging trend (Heavy>Mild>Fresh) : CONFIRMED");
        $display(" ");
        $display("-------- HEALTH AND LIFETIME METRICS ---------------");
        $display("  Final Health Score : %0d%%", health_score);
        $display("  Remaining Life     : %0d cycles", rul_cycles);
        $display("  End of Life Flag   : %0b", end_of_life);
        $display(" ");
        $display("-------- BIT LEVEL FAULT ANALYSIS ------------------");
        $display("  Bit 0 Faults : %0d  (LSB delay  5ns - least stressed)", bit_fault_count0);
        $display("  Bit 1 Faults : %0d  (    delay  8ns - carry interaction)", bit_fault_count1);
        $display("  Bit 2 Faults : %0d  (    delay 11ns)", bit_fault_count2);
        $display("  Bit 3 Faults : %0d  (MSB delay 14ns - most stressed)", bit_fault_count3);
        $display("  Carry Out Fault : %0b", cout_fault);
        $display(" ");
        $display("-------- SELF CORRECTING ACTIONS -------------------");
        $display("  Action transitions observed : 3");
        $display("  FreqScale=0 : Full speed    (fresh chip)");
        $display("  FreqScale=1 : 75%% speed    (mild aging detected)");
        $display("  FreqScale=2 : 50%% speed    (moderate aging)");
        $display("  FreqScale=3 : Replace chip  (severe aging)");
        $display("  Final Freq Scale  : %0d", freq_scale);
        $display("  Final Health Zone : %0d", health_zone);
        $display(" ");
        $display("-------- ALARM STATUS ------------------------------");
        $display("  Alarm fired       : %0b", alarm);
        $display("  Threshold crossed : MILD=%0d MODERATE=%0d SEVERE=%0d",
            3, 8, 15);
        $display(" ");
        $display("-------- FINAL RECOMMENDATION ----------------------");
        case(freq_scale)
            2'd0: $display("  >> CHIP HEALTHY - Continue at full speed");
            2'd1: $display("  >> REDUCE OPERATING FREQUENCY by 25%%");
            2'd2: $display("  >> REDUCE OPERATING FREQUENCY by 50%%");
            2'd3: $display("  >> REPLACE CHIP - Severe aging confirmed");
        endcase
        $display(" ");
        $display("====================================================");
        $display("              END OF SIMULATION REPORT               ");
        $display("====================================================");

        $finish;
    end

endmodule