/*
 * Copyright (c) 2024 Fabio Ramirez Stern
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
// `include "controller.v"
// `include "rotary_decoder.v"
// `include "led_ring_driver.v"

module tt_um_faramire_rotary_ring_wrapper (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  wire [11:0] led_mask_wire;
  wire [ 7:0] intensity_wire;

  wire rot_up_wire;
  wire rot_dn_wire;

  controller ctr1 (
    .clk(clk),
    .res_n(rst_n),
    .rot_up(rot_up_wire),
    .rot_dn(rot_dn_wire),
    .push(ui_in[2]),
    .intensity_in(ui_in[7:6]),

    .led_mask(led_mask_wire),
    .intensity_out(intensity_wire),
    .state_out(uo_out[5:1])
  );

  rotary_decoder rdec1 (
    .clk(clk),
    .res_n(rst_n),
    .rotary_clk(ui_in[0]),
    .rotary_dt(ui_in[1]),
    
    .rotation_up(rot_up_wire),
    .rotation_dn(rot_dn_wire)
  );

  led_ring_driver leddriv1 (
    .clk(clk),
    .res_n(rst_n),
    .led_mask(led_mask_wire),
    .colour(ui_in[5:3]),
    .intensity(intensity_wire),

    .led_dout(uo_out[0])
  );
  
  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out[7:6] = 2'b0;
  assign uio_out = 8'b0;
  assign uio_oe  = 8'b0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, ui_in[7:6], uio_in[7:0], 1'b0};

endmodule
