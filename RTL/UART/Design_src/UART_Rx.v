module UART_Rx (
    input clk,
    input rst,
    input Rx_En,
    input tick,
    input Rx_Data_in,
    output reg Data_valid,
    output reg parity_error,
    output reg [7:0] Rx_Data
);
parameter  IDEL   = 3'b000,
           START  = 3'b001,
           DATA   = 3'b010,
           PARITY = 3'b011,
           STOP   = 3'b100;

reg [2:0] current_state,next_state;
reg received_parity;
reg [2:0]bit_count;
reg [3:0] tick_count;
reg [7:0]Data_Backup;
always @ (posedge clk or negedge rst) begin
    if(!rst)
    current_state <= IDEL;
    else
    current_state <= next_state;
end

always @ (*) begin
    case (current_state)
    IDEL : 
           if(Rx_En && Rx_Data_in == 1'b0)
               next_state = START;
         else
         next_state = IDEL;
    START : 
        if (tick && tick_count == 4'd7) begin
            
          if(Rx_Data_in == 1'b0)
          next_state = DATA;
          else
          next_state = IDEL;
        end
           else
             next_state = START;
    DATA  : 
           if (tick && tick_count == 4'd15 && bit_count == 3'd7)
           next_state = PARITY;
           else
           next_state = DATA;
    PARITY :
        if (tick && tick_count == 4'd15) begin
           next_state = STOP;
        end
        else
        next_state = PARITY;
    STOP  :if (tick && tick_count == 4'd15) begin
           next_state = IDEL;
         end
          else
           next_state = STOP;
    default :
    next_state = IDEL;
endcase
end

always @ (posedge clk or negedge rst) begin
    if(!rst) begin
        bit_count <= 0;
        Data_Backup <= 0;
        Rx_Data <= 0;
        tick_count <= 0;
        received_parity <= 0;
        Data_valid <= 0;
        parity_error <= 0;
    end
    else begin
        Data_valid <= 1'b0;
        case (current_state)
        IDEL : begin 
            bit_count <= 0;
            tick_count <= 1'b0;
        end
        START : begin
            if (tick)begin
                if(tick_count == 4'd7) // Reached Middle of start bit 
                 tick_count <= 0;
                 else
                 tick_count <= tick_count + 1;
            end
        end
        DATA : begin
            if (tick) begin
                if (tick_count == 4'd15) begin
                     Data_Backup[bit_count] <= Rx_Data_in; // Sample exactly in the middle
                     tick_count <= 0;
                     if (bit_count < 7) begin
                        bit_count <= bit_count + 1;
                     end
                end
                else
                    tick_count <= tick_count +1;
            end
        end
        PARITY : begin
            if (tick) begin
                if (tick_count == 4'd15) begin
                    received_parity <= Rx_Data_in; 
                    tick_count <= 0;
                end
                else
                tick_count <= tick_count + 1;
                
            end
        end
           
        STOP : begin
            if (tick) begin
                if (tick_count== 4'd15) begin
                    tick_count <= 0;
                    if (Rx_Data_in == 1'b1) begin // valid stop bit detcted
                        if (received_parity == ^Data_Backup) begin
                            Rx_Data <= Data_Backup;
                            Data_valid <= 1'b1;
                            parity_error <= 1'b0;
                        end
                        else
                        parity_error <= 1'b1;
                    end
                end
                else
                tick_count <= tick_count + 1;
                
            end
        end
        default : ;
        endcase
    end
end
endmodule

