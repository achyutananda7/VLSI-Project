`timescale 1ns/1ps
/*
module tb_boot_rom;

    reg clk;
    reg en;
    reg [7:0] addr;
    wire [7:0] data_out;

    integer i;

    // DUT Instantiation
    boot_rom dut (
        .clk(clk),
        .en(en),
        .addr(addr),
        .data_out(data_out)
    );

    // Clock Generation (10 ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Display complete message stored in ROM
    initial begin
        en   = 0;
        addr = 0;
#10         en = 1;

    
            addr = i;

        $write("\nBoot Message = ");

        for(i = 0; i < 16; i = i + 1) begin
            $write("%c", dut.rom_mem[i]);
    end
          
        $display("\n");
          $finish;
    end

    // Read ROM contents sequentially


    // Monitor Address and Data
    initial begin
        $monitor("Time=%0t ns  Addr=%0d  Data=%h",
                  $time, addr, data_out);
    end

    // Waveform Dump
    initial begin
        $dumpfile("boot_rom.vcd");
        $dumpvars(0, tb_boot_rom);
    end

endmodule
*/
// `timescale 1ns/1ps

// module tb_boot_rom;

//     reg clk;
//     reg en;
//     reg [7:0] addr;
//     wire [7:0] data_out;

//     integer i;

//     // DUT Instantiation
//     boot_rom dut (
//         .clk(clk),
//         .en(en),
//         .addr(addr),
//         .data_out(data_out)
//     );

//     // Clock Generation (10 ns period)
//     initial begin
//         clk = 0;
//         forever #5 clk = ~clk;
//     end

//     // Fix the time formatting for $monitor
//     initial begin
//         // -9 scales to nanoseconds, 0 decimal places, adds " ns" suffix
//         $timeformat(-9, 0, " ns", 10);
//     end


//     // initial begin
//     //     $write("\nBoot Message = ");

//     //     for(i = 0; i < 16; i = i + 1) begin
//     //         $write("%c", dut.rom_mem[i]);
//     //     end
        
//     //     $display("\n");
//     // end

    
//     initial begin
//         en   = 0;
//         addr = 0;

//         // Wait for 1 clock cycle
//         #10;
//         en = 1;
//          $write("\nBoot Message = ");
//         // Drive the address pins sequentially
//         for(i = 0; i < 16; i = i + 1) begin
             
//             addr = i;
//             $write("%c", dut.rom_mem[i]);
//             #10; // Wait 1 clock cycle for data to appear
//         end
//         $display("\n");
//         // Wait a couple of clock cycles before ending the simulation
//         #20;
//         $finish;
//     end

//     initial begin
//         // Because of $timeformat, %0t will now print properly without us hardcoding "ns"
//         $monitor("Time=%0t  Addr=%0d  Data=%h", $time, addr, data_out);
//     end

//     // Waveform Dump
//     initial begin
//         $dumpfile("boot_rom.vcd");
//         $dumpvars(0, tb_boot_rom);
//     end

// endmodule

`timescale 1ns/1ps

module tb_boot_rom;

    reg clk;
    reg en;
    reg [7:0] addr;
    wire [7:0] data_out;

    integer i;

    // DUT Instantiation
    boot_rom dut (
        .clk(clk),
        .en(en),
        .addr(addr),
        .data_out(data_out)
    );

    // Clock Generation (10 ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Configure clean time formatting for $monitor
    initial begin
        $timeformat(-9, 0, " ns", 10);
    end

    // Corrected Single-Loop Read Block
    initial begin
        en   = 0;
        addr = 0;

        // Synchronize to the negative edge to cleanly enable the ROM
        @(negedge clk);
        en = 1;
         
        // Drive address pins exactly on the clock edge
        for(i = 1; i <= 16; i = i + 1) begin
            @(posedge clk);
            addr <= i; // Non-blocking assignment aligns perfectly with the ROM update
        end
        
        // Let the final data value settle, then finish
         $finish;
    end

    // Monitor prints exactly once per clock cycle now
    initial begin
        $monitor("Time=%0t  Addr=%0d  Data=%h  Char=%c", $time, addr, data_out, data_out);
    end
endmodule