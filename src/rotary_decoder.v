/*
 * Copyright (c) 2024 Fabio Ramirez Stern
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module rotary_decoder (
  
  /*
  * Rotary Encoder Decoder
  * Takes the two outputs of a rotary coder and determines in which direction it was turned. Output as one hod encoding.
  * rotary_clk and rotary_dt can be swapped to change direction, their connection should be arbitrary.
  */

  input wire clk, // 40MHz clock
  input wire res_n, // active low reset
  input wire rotary_clk, // output labeled clk of the rotary encoder (active low)
  input wire rotary_dt,  // output labeled dt  of the rotary encoder (active low)
  output reg rotation_up,  // goes high for one clock cycle if rotated upwards (clockwise)
  output reg rotation_dn   // goes high for one clock cycle if rotated downwards (counter clockwise)
);

  reg up_detected;
  reg dn_detected;
  reg [1:0] state;

  // FSM states
  localparam DETECTING = 2'b00;
  localparam OUTPUT    = 2'b01;
  localparam PAUSE     = 2'b10;
  localparam WAIT      = 2'b11;

  // Pause counter
  reg [15:0] pause_counter;

  always @(posedge clk) begin // process to monitor encoder
    
    if (!res_n) begin // reset
      rotation_up <= 0;
      rotation_dn <= 0;
      state <= DETECTING;
    end else begin

      case(state) // FSM

        DETECTING: begin
          if (!rotary_clk) begin // movement detected
            if (!rotary_dt) begin // rotary_dt already high => up movement
              up_detected <= 1;
              dn_detected <= 0;
              state <= OUTPUT;
            end else begin       // rotary_dt still low => down movement
              up_detected <= 0;
              dn_detected <= 1;
              state <= OUTPUT;
            end
          end
        end // DETECTING

        OUTPUT: begin // copy the detected state to the outputs and go to next state where they will be set to 0 again => on for one clock
          rotation_up <= up_detected;
          rotation_dn <= dn_detected;
          pause_counter = 16'b0;
          state <= PAUSE;
        end //OUTPUT

        PAUSE: begin // pause for 1 ms to debounce (40k clock cycles)
          rotation_up <= 0;
          rotation_dn <= 0;
          if (pause_counter == 16'b1001_1100_0011_1111) begin
            state <= WAIT;
          end else begin
            pause_counter = pause_counter + 16'b1;
          end
        end // PAUSE

        WAIT: begin // wait until both inputs are high again, then transition to detecting again
          if (rotary_clk && rotary_dt) begin
            state <= DETECTING;
          end          
        end // WAIT

        default:;
      endcase

    end

  end
endmodule