module health_rul_calculator(
    input        clk,
    input        reset,
    input  [7:0] mismatch_count,
    input  [7:0] cycle_count,

    output reg [6:0] health_score,  // 0 to 100
    output reg [7:0] rul_cycles,    // remaining useful life
    output reg       end_of_life    // HIGH when health < 20%
);

    parameter MAX_MISMATCHES = 50;
    parameter EOL_THRESHOLD  = 20;

    reg [7:0] prev_mismatch;
    reg [7:0] mismatch_rate;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            health_score  <= 100;
            rul_cycles    <= 255;
            end_of_life   <= 0;
            prev_mismatch <= 0;
            mismatch_rate <= 0;
        end
        else begin

            // --- Health Score ---
            if (mismatch_count >= MAX_MISMATCHES)
                health_score <= 0;
            else
                health_score <= 100 - ((mismatch_count * 100) / MAX_MISMATCHES);

            // --- Mismatch Rate (updated every 16 cycles) ---
            if (cycle_count[3:0] == 4'b0000) begin
                mismatch_rate <= mismatch_count - prev_mismatch;
                prev_mismatch <= mismatch_count;
            end

            // --- RUL ---
            if (mismatch_rate == 0)
                rul_cycles <= 255;
            else begin
                if (mismatch_count >= MAX_MISMATCHES)
                    rul_cycles <= 0;
                else
                    rul_cycles <= ((MAX_MISMATCHES - mismatch_count) * 16)
                                  / mismatch_rate;
            end

            // --- End of Life ---
            if (health_score <= EOL_THRESHOLD)
                end_of_life <= 1;
            else
                end_of_life <= 0;

        end
    end

endmodule