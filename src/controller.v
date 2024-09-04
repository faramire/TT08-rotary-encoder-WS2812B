/*
 * Copyright (c) 2024 Fabio Ramirez Stern
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module controller (
  input  wire clk,    // clock (40 Mhz)
  input  wire res_n,  // active low reset
  input  wire rot_up,
  input  wire rot_dn,
  input  wire push,   // push button
  input  wire [1:0] intensity_in,

  output reg  refresh,
  output wire [11:0] led_mask,
  output reg  [ 7:0] intensity_out,
  output wire [ 4:0] state_out
);

  // State
  reg inverted;
  reg [3:0] led_binary;
  assign state_out = {inverted, led_binary};

  reg [11:0] led_mask_i;
  assign led_mask = {12{inverted}} ^ led_mask_i;
  
  // LED
  always @(posedge clk) begin
    if (!res_n) begin //reset
      refresh <= 0;
      led_mask_i <= 12'b0000_0000_0001;
      led_binary <= 4'b0;
      inverted <= 0;
    end else begin

      // Inversion
      if (push) begin
        inverted <= ~inverted;
      end

      // Counting
      if (rot_up) begin
        led_mask_i = (led_mask_i << 1) | (led_mask_i >> 11); // shift with rotate
      end else if (rot_dn) begin
        led_mask_i = (led_mask_i >> 1) | (led_mask_i >> 11);
      end

      // Intensity
      case(intensity_in[1:0])
        2'b00: intensity_out = 8'b0000_0001;
        2'b01: intensity_out = 8'b0000_0010;
        2'b10: intensity_out = 8'b0000_1000;
        2'b11: intensity_out = 8'b0010_0000;
      endcase

    end
  end

endmodule