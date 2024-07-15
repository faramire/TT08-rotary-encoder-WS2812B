/*
 * Copyright (c) 2024 Fabio Ramirez Stern
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module debounce (
  input wire clock, // clock
  input wire res_n, // active low reset
  input wire in,    // the input to be debounced
  output reg out    // debounced output
);


  always @(posedge clock) begin
    
    if (!res_n) begin
      //
    end

  end
endmodule