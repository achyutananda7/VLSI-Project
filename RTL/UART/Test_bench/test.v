`timescale 1ns / 1ps

module tb_UART_Top();

    // ==========================================
    // 1. Signals
    // ==========================================
    reg clk;
    reg rst;
    reg Tx_En;
    reg [7:0] Tx_Data_in;
    reg Rx_En;

    wire Tx_Pin;
    wire Tx_Busy;
    wire Rx_Data_valid;
    wire Rx_parity_error;
    wire [7:0] Rx_Data_out;

    // ==========================================
    // 2. Regression Tracking Variables
    // ==========================================
    integer tests_passed = 0;
    integer tests_failed = 0;
    integer i;

    reg [7:0] test_data [0:4]; 

    // ==========================================
    // 3. Instantiate the Top Module
    // ==========================================
    UART_Top uut (
        .clk(clk),
        .rst(rst),
        .Tx_En(Tx_En),
        .Tx_Data_in(Tx_Data_in),
        .Tx_pin(Tx_Pin),
        .Busy(Tx_Busy),
        .Rx_En(Rx_En),
        .Rx_pin(Tx_Pin),          
        .Data_valid(Rx_Data_valid),
        .parity_error(Rx_parity_error),
        .Rx_Data_Out(Rx_Data_out)
    );

    // ==========================================
    // 4. Generate the Clock (50 MHz)
    // ==========================================
    initial clk = 0;
    always #10 clk = ~clk;

    // ==========================================
    // 5. The Main Regression Flow
    // ==========================================
    initial begin
        // Setup 5 distinct patterns in BINARY
        test_data[0] = 8'b10100101; 
        test_data[1] = 8'b01011010; 
        test_data[2] = 8'b00000001; // <--- WE ARE SENDING A 1 HERE!
        test_data[3] = 8'b11111111; 
        test_data[4] = 8'b00000000; 

        rst = 0;
        Tx_En = 0;
        Tx_Data_in = 0;
        Rx_En = 1; 

        #100;
        rst = 1;
        #100;

        $display("========================================");
        $display("   STARTING UART REGRESSION TEST");
        $display("========================================");

        for (i = 0; i < 5; i = i + 1) begin
            send_and_check(test_data[i]);
            #200000; 
        end

        $display("========================================");
        $display("   REGRESSION COMPLETE");
        $display("   Passed: %0d", tests_passed);
        $display("   Failed: %0d", tests_failed);
        $display("========================================");
        $finish; 
    end
initial begin
    $dumpfile("tb_UART_Top.vcd");
    $dumpvars(0, tb_UART_Top);
end
    // ==========================================
    // 6. The System Monitor (BINARY MODE)
    // ==========================================
    initial begin
        $display("-------------------------------------------------------------------------------------------------------");
        $display("  Time  | Tx_Data_in | Tx_Busy | Tx_State | Wire (Tx->Rx) | Rx_State | Rx_Data_out | Valid | Parity_Err");
        $display("-------------------------------------------------------------------------------------------------------");
        // Notice we changed %h to %b so it prints 1s and 0s!
        $monitor("%7t |  %b  |    %b    |    %0d     |       %b       |    %0d     |  %b  |   %b   |     %b", 
                 $time, Tx_Data_in, Tx_Busy, uut.Tx.current_state, Tx_Pin, uut.Rx.current_state, Rx_Data_out, Rx_Data_valid, Rx_parity_error);
    end

    // ==========================================
    // 7. The Self-Checking Task
    // ==========================================
    task send_and_check(input [7:0] data_to_send);
        begin
            $display("\n>>> Initiating Transfer for Byte: %b", data_to_send);

            @(posedge clk);
            Tx_Data_in = data_to_send;
            Tx_En = 1;
            @(posedge clk);
            Tx_En = 0; 

            fork : wait_for_data
                begin
                    @(posedge Rx_Data_valid);
                    disable wait_for_data; 
                end
                begin
                    repeat(100000) @(posedge clk);
                    $display("   [ERROR] Timeout! Receiver never asserted Data_valid.");
                    disable wait_for_data;
                end
            join

            if (Rx_Data_valid) begin
                if (Rx_Data_out == data_to_send && Rx_parity_error == 0) begin
                    $display("<<< [PASS] Received %b correctly. No errors.\n", Rx_Data_out);
                    tests_passed = tests_passed + 1;
                end else begin
                    $display("<<< [FAIL] Expected %b, Got %b\n", data_to_send, Rx_Data_out);
                    tests_failed = tests_failed + 1;
                end
            end else begin
                tests_failed = tests_failed + 1; 
            end
        end
    endtask

endmodule