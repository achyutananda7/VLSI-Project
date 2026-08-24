module Alu_decoder (
    input [6:0] opcode,
    input [2:0] funct3,
    input funct7_of_bit5,
    input [1:0] Alu_opcode,
    output reg [3:0] Alu_control
);
always @ (*) begin
    case (Alu_opcode)
    2'b00 : begin
        Alu_control = 4'b0000; //add
    end
    2'b01 : begin
        Alu_control = 4'b0001; //sub
    end
    2'b10 : begin
        case(funct3)
        3'b000 : begin
            if (funct7_of_bit5 == 1'b1) begin
                Alu_control = 4'b0001; // sub
            end
            else begin
                Alu_control = 4'b0000; // Add
            end
        end
        3'b010 : begin
            Alu_control = 4'b0101; // SLT
        end
        3'b011 : begin
            Alu_control = 4'b0110; // SLTU
        end
        3'b100 : begin
            Alu_control = 4'b0100; // XOR
        end
        // funct7b5 = 0 → SRL
        // funct7b5 = 1 → SRA
        3'b101 : begin
            if (funct7_of_bit5 == 1'b1) begin
                Alu_control = 4'b1100; // SRA
            end
            else begin
                Alu_control = 4'b1011; // SRL
            end
        end
        3'b110 : begin
            Alu_control = 4'b0011; // OR
        end
        3'b111 : begin
            Alu_control = 4'b0010; // AND
        end
        default : Alu_control = 4'bxxxx;
        endcase
    end

    2'b11 : begin
        case (opcode)
        7'b0110111 : Alu_control = 4'b0111; // LUI
        7'b0010111 : Alu_control = 4'b1000; // AUIPC
        default : Alu_control = 4'bxxxx;
        endcase
    end
    default : begin
        Alu_control = 4'bxxxx;
    end
    endcase
end
endmodule