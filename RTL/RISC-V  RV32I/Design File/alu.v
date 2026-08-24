module alu (
    input [31:0] A,
    input [31:0] B,
    input [3:0] Alu_control,
    output reg [31:0] Alu_result,
    output  zero
);
reg overflow;
wire slt = (A[31]==B[31]) ? (A < B) : A[31]; // Set less than
wire sltu = A < B; // Set less than unsign
reg [32:0] temp;
reg carry;

always @ (*) begin
    case (Alu_control)
    4'b0000 : begin
               temp = A + B;
               Alu_result = temp [31:0];
               carry = temp[32];
               overflow = (~(A[31] ^ B[31])) & (A[31] ^ Alu_result[31]);
         end
    4'b0001 : begin
        temp = A - B;
        Alu_result = temp [31:0];
        carry = temp[32];
        overflow = (A[31] ^ B[31]) & (A[31] ^ Alu_result[31]);
    end
    4'b0010 : Alu_result = A & B; // AND
    4'b0011 : Alu_result = A | B; // OR
    4'b0100 : Alu_result = A ^ B; // XOR
    4'b0101 : Alu_result = {31'b0, slt}; // Set Less Than
    4'b0110 : Alu_result = {31'b0, sltu}; // Set Less Than Unsigned
    4'b0111 : Alu_result = {A[31:12],12'b0}; // LUI = Load Upper Immidiate
    4'b1000 : Alu_result = A + {B[31:12],12'b0}; // AUIPC
    4'b1001 : Alu_result = {B[31:12],12'b0};
    4'b1010 : Alu_result = A << B[4:0]; 
    4'b1011 : Alu_result = A >> B[4:0]; 
    4'b1100 : Alu_result = $signed(A) >>> B[4:0]; // SRA = Shift Right Arthmatic 
    default : Alu_result = 32'bx;
    endcase
end
assign zero = (Alu_result == 0);
endmodule 