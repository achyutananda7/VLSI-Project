module main_decoder (
input [6:0] opcode,
output reg Regwrite,alu_src,memwrite,branch,jump,
output reg [1:0] Immgen_src,result_src,Alu_op
);
always @ (*) begin
    case (opcode)
    7'b000_000_0 : begin
        Regwrite = 1'b0;
        alu_src = 1'b0;
        memwrite = 1'b0;
        branch = 1'b0;
        jump = 1'b0;
        Immgen_src =2'b00;
        result_src = 2'b00;
        Alu_op = 2'b00;
    end
    7'b000_001_1:begin       // The opcode 0000011 is for loading data from memory.
        Regwrite = 1'b1;
        alu_src = 1'b1;
        memwrite = 1'b1;
        branch = 1'b0;
        jump = 1'b0;
        Immgen_src = 2'b00;
        result_src = 2'b01;
        Alu_op = 2'b00;
     end
    7'b010_001_1: begin  // Opcode 0100011
        Regwrite = 1'b0;
        alu_src = 1'b1;
        memwrite = 1'b1;
        branch = 1'b0;
        jump = 1'b0;
        Immgen_src = 2'b00;
        result_src = 2'b00;
        Alu_op = 2'b00;
    end
    7'b011_001_1: begin 
        Regwrite = 1'b1;
        alu_src = 1'b0;
        memwrite = 1'b0;
        Immgen_src = 2'bxx;
        branch = 1'b0;
        jump = 1'b0;
        result_src = 2'b00;
        Alu_op = 2'b10;
    end
    7'b001_001_1: begin
        Regwrite=1'b1;
        alu_src=1'b1;
        memwrite=1'b0;
        Immgen_src=2'b00;
        branch=1'b0;
        jump=1'b0;
        result_src=2'b00;
        Alu_op=2'b10;
    end

    7'b110_001_1: begin
        Regwrite=1'b0;
        alu_src=1'b0;
        memwrite=1'b0;
        Immgen_src=2'b10;
        branch=1'b1;
        jump=1'b0;
        result_src=2'b00;
        Alu_op=2'b01;
    end

    7'b110_111_1: begin
        Regwrite=1'b1;
        alu_src=1'b0;
        memwrite=1'b0;
        Immgen_src=2'b11;
        branch=1'b0;
        jump=1'b1;
        result_src=2'b10;
        Alu_op=2'b00;
    end

    7'b110_011_1: begin
        Regwrite=1'b1;
        alu_src=1'b1;
        memwrite=1'b0;
        Immgen_src=2'b00;
        branch=1'b0;
        jump=1'b1;
        result_src=2'b10;
        Alu_op=2'b00;
    end

    7'b011_011_1: begin
        Regwrite=1'b1;
        alu_src=1'b1;
        memwrite=1'b0;
        Immgen_src=2'b00;
        branch=1'b0;
        jump=1'b0;
        result_src=2'b00;
        Alu_op=2'b11;
    end

    7'b001_011_1: begin
        Regwrite=1'b1;
        alu_src=1'b1;
        memwrite=1'b0;
        Immgen_src=2'b00;
        branch=1'b0;
        jump=1'b0;
        result_src=2'b00;
        Alu_op=2'b01;
    end
    default : begin
        Regwrite=1'b0;
        alu_src=1'b0;
        memwrite=1'b0;
        Immgen_src=2'b00;
        branch=1'b0;
        jump=1'b0;
        result_src=2'b00;
        Alu_op=2'b00;
    end
endcase
end
endmodule