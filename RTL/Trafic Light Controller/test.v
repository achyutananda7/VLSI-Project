`timescale 1ns / 1ps

module tb_traffic_light_fsm();

    reg clk;
    reg rst;
    wire [2:0] NS;
    wire [2:0] EW;

    // Instantiate the Unit Under Test (UUT)
    traffic_light_fsm uut (
        .clk(clk), 
        .rst(rst), 
        .NS(NS), 
        .EW(EW)
    );

    // Clock generation (10ns period)
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        rst = 1; // Assert reset high

        // Display formatting for simulation log
        $monitor("Time=%0t | State=%b | NS=%b | EW=%b | Timer=%d", 
                  $time, uut.current_state, NS, EW, uut.timer);

        // De-assert Reset (set to 0) to start the FSM
        #15 rst = 0; 

        // Let simulation run long enough to see a full cycle
        // Full cycle time = (20 + 5 + 2 + 20 + 5) * 10ns = 520ns approx
        #600;

        $finish;
    end
endmodule