module URT_Tx(
    input clk,
    input rst,
    input tick,
    input Tx_En,
    input [7:0] Data_in,
    output reg Data_out,
    output Busy
);
parameter IDEL = 3'b000,
          START = 3'b001,
          DATA  = 3'b010,
          PARITY = 3'b011,
          STOP  = 3'b100;
reg [2:0] current_state,next_state;
reg [2:0] bit_count;
reg [7:0] Data_Backup;
reg [3:0] tick_count;
reg parity_bit;

// Current State Logic
always @ (posedge clk or negedge rst) begin
    if(!rst)
    current_state <= IDEL;
    else
    current_state <= next_state;
end

// Next State Logic

always @ (*) begin
    case(current_state) 
    IDEL : 
            if(Tx_En)
            next_state = START;
            else
            next_state = IDEL;
    START : 
        if(tick && tick_count == 4'd15)
            next_state = DATA;
            else
            next_state = START;
    DATA :
            if (tick && tick_count == 4'd15 && (bit_count == 3'd7 ))
            next_state = PARITY;
            else
            next_state = DATA;
    PARITY : if(tick && tick_count == 4'd15 )
            next_state = STOP;
            else
            next_state = PARITY;
    STOP  : if(tick && tick_count == 4'd15 )
            next_state = IDEL;
            else
            next_state = STOP;
    default : 
            next_state = IDEL;
endcase
end

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        Data_out <= 1'b1;
        bit_count <= 0;
        tick_count <= 0;
        Data_Backup <= 0;
        parity_bit <= 0;
    end
    else begin
        case (current_state)
            IDEL : begin
                Data_out <= 1'b1;
                bit_count <= 0;
                tick_count <= 0;
         
               if (Tx_En) begin
                  Data_Backup <= Data_in;
                  parity_bit <= ^Data_in;
               end
            end
            START : begin
                Data_out <= 1'b0;
                if(tick) begin
                    if(tick_count == 4'd15)
                    tick_count <= 1'b0;
                    else
                    tick_count <= tick_count + 1;
                    end

            end
            DATA : begin
                Data_out <= Data_Backup[bit_count];
               if(tick) begin
                 if(tick_count == 4'd15) begin
                    tick_count<= 1'b0;
                    if(bit_count < 7)
                      bit_count <= bit_count + 1; 
                end
                else
                tick_count <= tick_count + 1;
               end 
            end
            PARITY : begin
                Data_out <= parity_bit; 
                if (tick) begin
                    if (tick_count == 4'd15) 
                        tick_count <= 0;
                        else
                        tick_count <= tick_count + 1; 
                end
            end
            STOP : begin
                Data_out <= 1'b1;
                if (tick) begin
                  if (tick_count==4'd15) begin
                    tick_count <= 1'b0;
                  end
                  else
                  tick_count <= tick_count + 1;
                    
                end
            end
            //default: 
        endcase
    end
end
assign Busy = (current_state != IDEL );
endmodule