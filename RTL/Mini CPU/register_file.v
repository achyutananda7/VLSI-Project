module register_file (
    input clk,
    input rst,
    input write_en,
    input [1:0] rd,
    input [1:0] rs1,
    input [1:0] rs2,
    input [7:0] write_data,

    output [7:0] data1,
    output [7:0] data2
);

reg [7:0] reg_file [0:3];

assign data1 = reg_file[rs1];
assign data2 = reg_file[rs2];

always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        reg_file[0] <= 0;
        reg_file[1] <= 0;
        reg_file[2] <= 0;
        reg_file[3] <= 0;
    end
    else if (write_en)
    begin
        reg_file[rd] <= write_data;
    end
end

endmodule