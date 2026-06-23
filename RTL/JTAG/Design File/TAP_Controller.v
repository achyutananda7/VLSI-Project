module TAP_Controller(
    input TMS,
    input TCK,
    input TRST,

    output reg Capture_DR,//Data Register
    output reg Shift_DR,
    output reg Update_DR,

    output reg Capture_IR,
    output reg Shift_IR,
    output reg Update_IR
);
parameter [3:0]
              Test_Logic_Reset = 4'b0000,
              Run_Test_Or_Idle = 4'b0001,
              Select_DR_Scan   = 4'b0010,
              Capture_DR_State = 4'b0011,
              Shift_DR_State   = 4'b0100,
              Exit1_DR         = 4'b0101,
              Pause_DR         = 4'b0110,
              Exit2_DR         = 4'b0111,
              Update_DR_State  = 4'b1000,

              Select_IR_Scan   = 4'b1001,
              Capture_IR_State = 4'b1010,
              Shift_IR_State   = 4'b1011,
              Exit1_IR         = 4'b1100,
              Pause_IR         = 4'b1101,
              Exit2_IR         = 4'b1110,
              Update_IR_State  = 4'b1111;

reg [3:0] Current_State,Next_State;
always @(posedge TCK or negedge TRST) begin
    if(!TRST) begin
        Current_State <= Test_Logic_Reset;
    end
    else begin
        Current_State <= Next_State;
    end
end

always @(*)begin
    case(Current_State)
        Test_Logic_Reset : begin
            if(TMS == 0) 
            Next_State <= Run_Test_Or_Idle;
            else
            Next_State <= Test_Logic_Reset;
        end

        Run_Test_Or_Idle : begin
            if(TMS == 1) 
            Next_State <= Select_DR_Scan;
            else
            Next_State <= Run_Test_Or_Idle;
        end

        Select_DR_Scan : begin
            if(TMS == 1)
            Next_State <= Select_IR_Scan;
            else
            Next_State <= Capture_DR_State;
        end

        Capture_DR_State : begin
            if (TMS == 1)
            Next_State <= Exit1_DR;
            else 
            Next_State <= Shift_DR_State;
        end

        Shift_DR_State : begin
            if (TMS == 1) 
            Next_State <= Exit1_DR;
            else 
            Next_State <= Shift_DR_State;
        end

        Exit1_DR : begin
            if (TMS == 1)
            Next_State <= Update_DR_State;
            else 
            Next_State <= Pause_DR;
        end

        Pause_DR : begin
            if (TMS == 1)
            Next_State <= Exit2_DR;
            else 
            Next_State <= Pause_DR;
        end

        Exit2_DR : begin
            if (TMS == 1)
            Next_State <= Update_DR_State;
            else
            Next_State <= Shift_DR_State;
        end

        Update_DR_State : begin
            if (TMS == 1)
            Next_State <= Select_DR_Scan;
            else 
            Next_State <= Run_Test_Or_Idle;
        end

        Select_IR_Scan : begin
            if (TMS == 1)
            Next_State <= Test_Logic_Reset;
            else
            Next_State <= Capture_IR_State;
        end

        Capture_IR_State : begin
            if (TMS == 1)
            Next_State <= Exit1_IR;
            else
            Next_State <= Shift_IR_State;
        end

        Shift_IR_State : begin
            if (TMS == 1)
            Next_State <= Exit1_IR;
            else
            Next_State <= Shift_IR_State;
        end

        Exit1_IR : begin
            if (TMS == 1) 
            Next_State <= Update_IR_State;
            else 
            Next_State <= Pause_IR;
        end

        Pause_IR : begin
            if (TMS == 1)
            Next_State <= Exit2_IR;
            else 
            Next_State <= Pause_IR;
        end

        Exit2_IR : begin
            if (TMS == 1)
            Next_State <= Update_IR_State;
            else
            Next_State <= Shift_IR_State;
        end

        Update_IR_State : begin
            if (TMS == 1)
            Next_State <= Select_DR_Scan;
            else 
            Next_State <= Run_Test_Or_Idle;
        end
        default : Next_State <= Test_Logic_Reset;
    endcase  
end

always @ (*) begin
    Capture_DR = 0;
    Shift_DR   = 0;
    Update_DR  = 0;
    Capture_IR = 0;
    Shift_IR   = 0;
    Update_IR  = 0;


    case(Current_State)
    Capture_DR_State : Capture_DR = 1'b1;
    Shift_DR_State : Shift_DR = 1'b1;
    Update_DR_State : Update_DR = 1'b1;
    Capture_IR_State : Capture_IR = 1'b1;
    Shift_IR_State : Shift_IR = 1'b1;
    Update_IR_State : Update_IR = 1'b1;
    endcase
end
endmodule
