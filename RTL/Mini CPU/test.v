module mini_cpu_tb;

reg clk;
reg rst;
reg [7:0] instruction;

wire [7:0] result;

mini_cpu uut (
    .clk(clk),
    .rst(rst),
    .instruction(instruction),
    .result(result)
);

always #5 clk = ~clk;

initial
begin
    clk = 0;
    rst = 1;
    instruction = 8'b0;

    #10;
    rst = 0;

    // Set R1 = 10
    uut.RF.reg_file[1] = 8'd10;

    // Set R2 = 5
    uut.RF.reg_file[2] = 8'd5;


    // ADD R0, R1, R2
    // opcode = 00
    // rd     = 00 -> R0
    // rs1    = 01 -> R1
    // rs2    = 10 -> R2

    instruction = 8'b00011010;

    #10;

    $display("ADD Result = %d", result);


    // SUB R0, R1, R2
    // opcode = 01

    instruction = 8'b01011010;

    #10;

    $display("SUB Result = %d", result);


    // AND R0, R1, R2
    // opcode = 10

    instruction = 8'b10011010;

    #10;

    $display("AND Result = %d", result);


    #10;

    $finish;

end

endmodule