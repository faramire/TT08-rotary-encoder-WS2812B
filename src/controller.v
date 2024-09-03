/*
 * Copyright (c) 2024 Fabio Ramirez Stern
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module controller (
  input  wire clk,   // clock (40 Mhz)
  input  wire res_n,   // active low reset
  input  wire rot_up,
  input  wire rot_dn,
  input  wire push,
  input  wire [1:0] intensity_in,

  output wire refresh,
  output wire [11:0] led_mask;
  output wire [ 7:0] intensity;
  output wire [ 4:0] state_out
)
  
  //

endmodule