module twin_monitor_selfcorrect(
    input        clk,
    input        reset,
    input  [3:0] Sum_nominal,
    input  [3:0] Sum_aged,
    input        Cout_nominal,
    input        Cout_aged,

    output reg [7:0] mismatch_count,
    output reg       alarm,
    output reg [3:0] bit_fault_count0,
    output reg [3:0] bit_fault_count1,
    output reg [3:0] bit_fault_count2,
    output reg [3:0] bit_fault_count3,
    output reg       cout_fault,

    // NEW corrective action outputs
    output reg [1:0] freq_scale,      // 0=full, 1=75%, 2=50%, 3=replace
    output reg       action_taken,    // pulses HIGH when action changes
    output reg [1:0] health_zone      // 0=healthy,1=mild,2=moderate,3=severe
);

//    parameter ALARM_THRESHOLD    = 5;
//    parameter MILD_THRESHOLD     = 5;
//    parameter MODERATE_THRESHOLD = 15;
//    parameter SEVERE_THRESHOLD   = 30;

 parameter ALARM_THRESHOLD    = 3;
    parameter MILD_THRESHOLD     = 3;
    parameter MODERATE_THRESHOLD = 8;
    parameter SEVERE_THRESHOLD   = 15;


    wire [3:0] bit_mismatch;
    wire       any_mismatch;

    assign bit_mismatch = Sum_nominal ^ Sum_aged;
    assign any_mismatch = |bit_mismatch | (Cout_nominal ^ Cout_aged);

    // Glitch filter - negedge based
    reg any_mismatch_d;
    always @(negedge clk or posedge reset) begin
        if (reset) any_mismatch_d <= 0;
        else       any_mismatch_d <= any_mismatch;
    end

    wire stable_mismatch = any_mismatch & any_mismatch_d;

    // Previous freq_scale - to detect when action changes
    reg [1:0] freq_scale_prev;

    always @(negedge clk or posedge reset) begin
        if (reset) begin
            mismatch_count   <= 0;
            alarm            <= 0;
            bit_fault_count0 <= 0;
            bit_fault_count1 <= 0;
            bit_fault_count2 <= 0;
            bit_fault_count3 <= 0;
            cout_fault       <= 0;
            freq_scale       <= 2'd0;
            freq_scale_prev  <= 2'd0;
            action_taken     <= 0;
            health_zone      <= 2'd0;
        end
        else begin

            // --- Mismatch counting ---
            if (stable_mismatch) begin
                mismatch_count <= mismatch_count + 1;
                if (bit_mismatch[0]) bit_fault_count0 <= bit_fault_count0 + 1;
                if (bit_mismatch[1]) bit_fault_count1 <= bit_fault_count1 + 1;
                if (bit_mismatch[2]) bit_fault_count2 <= bit_fault_count2 + 1;
                if (bit_mismatch[3]) bit_fault_count3 <= bit_fault_count3 + 1;
                if (Cout_nominal ^ Cout_aged) cout_fault <= 1;
            end

            // --- Alarm ---
            if (mismatch_count >= ALARM_THRESHOLD)
                alarm <= 1;

            // --- Corrective action decision ---
            freq_scale_prev <= freq_scale;

            if (mismatch_count < MILD_THRESHOLD) begin
                freq_scale  <= 2'd0;
                health_zone <= 2'd0;
            end
            else if (mismatch_count < MODERATE_THRESHOLD) begin
                freq_scale  <= 2'd1;   // reduce to 75%
                health_zone <= 2'd1;
            end
            else if (mismatch_count < SEVERE_THRESHOLD) begin
                freq_scale  <= 2'd2;   // reduce to 50%
                health_zone <= 2'd2;
            end
            else begin
                freq_scale  <= 2'd3;   // replace chip
                health_zone <= 2'd3;
            end

            // --- Action taken pulse ---
            // fires whenever corrective action level changes
            if (freq_scale != freq_scale_prev)
                action_taken <= 1;
            else
                action_taken <= 0;

        end
    end

endmodule
