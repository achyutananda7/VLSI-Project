module control_unit (
    input [1:0] opcode,
    output reg write_en,
    output reg [1:0] alu_op
);

always @(*)
begin
    write_en = 1'b0;
    alu_op = 2'b00;

    case(opcode)

        2'b00: begin
            // ADD
            write_en = 1'b1;
            alu_op = 2'b00;
        end

        2'b01: begin
            // SUB
            write_en = 1'b1;
            alu_op = 2'b01;
        end

        2'b10: begin
            // AND
            write_en = 1'b1;
            alu_op = 2'b10;
        end

        default: begin
            write_en = 1'b0;
        end

    endcase
end

endmodule