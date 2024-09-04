/*
 * Copyright (c) 2024 Fabio Ramirez Stern
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module led_ring_driver (
  input  wire clk,     // clock (40 Mhz)
  input  wire res_n,   // active low reset
  input  wire refresh, // enables transmission start
  input  wire [11:0] led_mask, // one hot mask of which LEDs to turn on and which to keep off
  input  wire [ 2:0] colour,   // GRB mask
  input  wire [ 7:0] intensity,  // intensity for LEDs that are 1

  output reg led_dout, // digital output to LEDs
  output reg busy
);

  reg skip_calc;

  // input latches
  reg [11:0] reg_led_mask;
  reg  [2:0] reg_colour;
  reg  [7:0] reg_intensity;

  // FSM states
  reg [3:0] state;
  localparam IDLE = 2'b00; // idle, wait for refresh
  localparam CALC = 2'b01; // calc next timings
  localparam OUTP = 2'b10; // send data to LEDs, retun to CALC
  localparam TRES = 2'b11; // wait 50us (minimum reset time)

  // timing counters
  reg  [5:0] tl_counter; // counter for low time (34/18 clk cycles)
  reg  [5:0] tl_max;
  reg  [5:0] th_counter; // counter for high time (16/32 clk cycles)
  reg  [5:0] th_max;
  reg [11:0] rs_counter; // counter for reset time (4000 clk cycles)
  reg  [3:0] led_pos;    // led position counter (0..11)
  reg  [1:0] grb_pos;    // green, red, blue counter (0..2)
  reg  [3:0] byte_pos;   // grb byte counter (0..7)


  always @(posedge clk) begin
    
    if (!res_n) begin
      led_dout <= 0;
      state <= IDLE;
    end else begin
    case(state)

      IDLE: begin // wait for refresh to go high, initiate all registers for transmission
        if (refresh) begin
          reg_led_mask  <= led_mask;
          reg_colour    <= colour;
          reg_intensity <= intensity;
          rs_counter <= 0;
          tl_counter <= 0;
          tl_counter <= 0;
          tl_counter <= 0;
          skip_calc <= 0;
          led_pos  <= 0;
          grb_pos  <= 0;
          byte_pos <= 0;
          state <= CALC;
        end
      end // IDLE

      CALC: begin // calculate the timings needed to transmit the next bit, count through bytes of colour, the three colours and the 12 LEDs
        if(reg_led_mask[led_pos]) begin // if current LED should be on
          if(reg_colour[grb_pos] && reg_intensity[byte_pos]) begin // if current colour should be on and current intensity bit is 1
            tl_max <= 32;
            th_max <= 18;
          end else begin
            tl_max <= 16;
            tl_max <= 34;
          end

          if (byte_pos < 7) begin // advance to next bit
            byte_pos = byte_pos + 1;
          end else begin // end of colour byte, advance to next colour byte
            if (grb_pos < 2) begin
              byte_pos <= 0;
              grb_pos <= grb_pos + 1;
            end else begin // end of LED colour word, advance to next LED
              if (led_pos < 11) begin
                byte_pos <= 0;
                grb_pos <= 0;
                led_pos <= led_pos + 1;
              end else begin // last bit of last colour of last LED, ie end of transmission, do not go back
                skip_calc <= 1;
              end
            end
          end
        end

        state <= OUTP;
      end // CALC

      OUTP: begin // output one bit according to the WS281B
        if (tl_counter < tl_max) begin // hold low, count cycles
          led_dout <= 0;
          tl_counter = tl_counter + 6'b1;
        end else begin // hold high, count cycles
          if(th_counter < th_max) begin
            led_dout <= 1;
            th_counter <= th_counter + 6'b1;
          end else begin
            if(skip_calc) begin // end of transmission? don't go to CALC, advance to TRES
              state <= TRES;
            end else begin
              state <= CALC;
            end
          end
        end
      end // OUTP

      TRES: begin // wait for the minimum reset time (t_res), then advance to IDLE
        led_dout <= 0;
        if (rs_counter == 11'b111_1101_0000) begin
          state <= IDLE;
        end else begin
          rs_counter <= rs_counter + 11'b1;
        end
      end // TRES

      default:;
    endcase
    end

  end
endmodule