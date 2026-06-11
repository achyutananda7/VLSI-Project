module boot_rom(
    input clk,en,
    input [7:0]addr,
    output reg [7:0]data_out
);
reg [7:0] rom_mem[0:255];


integer i;

initial begin
     data_out = 8'h00;
    for(i=0;i<256;i=i+1)
        rom_mem[i] = 8'h00;

    $readmemh("boot_code.hex",rom_mem);

end

always @(posedge clk) begin
    if (en)begin
        data_out<=rom_mem[addr];
    end
    else
    data_out <= 8'h00;
end
endmodule


// initial begin
//     $readmemh("boot_code.hex",rom_mem);
//     // $readmemh("filename", memory_name);  
//     //Read hexadecimal values from a file and store them into a memory array.
// end

// $readmemh read memory in hexadecimal format
// "boot_code.hex" this is a file name where code is store in hex no.
// rom_mem This is the memory array where data will be stored.
/*What Happens Internally?

Suppose file contain :
boot_code.hex
12
34
56
78
AA
BB

When simulation starts:

$readmemh("boot_code.hex", rom_mem);

loads:

rom_mem[0] = 8'h12
rom_mem[1] = 8'h34
rom_mem[2] = 8'h56
rom_mem[3] = 8'h78
rom_mem[4] = 8'hAA
rom_mem[5] = 8'hBB */