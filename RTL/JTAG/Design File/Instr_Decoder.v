module Instruction_Decoder (
    input  wire [3:0] Instr_for_Decoder,

    output reg        Select_Bypass,
    output reg        Select_IDCODE,
    output reg        Select_BSR      // NEW: Controls the Boundary Scan Register path
);

localparam [3:0] INST_BYPASS = 4'b1111;
localparam [3:0] INST_IDCODE = 4'b0001;
localparam [3:0] INST_EXTEST = 4'b0010; // NEW: Standard JTAG opcode for Boundary Scan

always @ (*) begin
    // 1. Safety Defaults: Turn everything off first
    Select_Bypass = 1'b0;
    Select_IDCODE = 1'b0;
    Select_BSR    = 1'b0;

    // 2. Decoder Case Routing
    case(Instr_for_Decoder)
        
        INST_BYPASS : begin
            Select_Bypass = 1'b1;
        end
        
        INST_IDCODE : begin
            Select_IDCODE = 1'b1;
        end
        
        INST_EXTEST : begin
            Select_BSR    = 1'b1; // Wakes up the boundary cells and enters Test Mode
        end
        
        // Safety Fallback: Unknown codes drop directly into Bypass
        default : begin
            Select_Bypass = 1'b1;
        end
    endcase
end
endmodule