module single_cycle_core_top_tb;
reg clk,rst;

single_cycle_core_top uut(
    .clk(clk),
    .rst(rst)
);
always #5 clk = ~clk;

initial begin
    clk = 0;
    rst = 1;
    #20;
    rst = 0;
    #1000; // simulation run time 
    $finish;
end

initial begin
    $dumpfile("Risc.vcd");
    $dumpvars();
end

initial begin
    $monitor ("Time = %t | PC : %h | instr : %h | Alu_result : %h | memwrite = %b | Write_data = %h ",
     $time, uut.PC, uut.instr, uut.Alu_result, uut.memwrite, uut.Write_data);
end
endmodule