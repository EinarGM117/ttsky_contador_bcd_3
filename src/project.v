// /*
//  * Copyright (c) 2024 Your Name
//  * SPDX-License-Identifier: Apache-2.0
//  */

// `default_nettype none

// module tt_um_example (
//     input  wire [7:0] ui_in,    // Dedicated inputs
//     output wire [7:0] uo_out,   // Dedicated outputs
//     input  wire [7:0] uio_in,   // IOs: Input path
//     output wire [7:0] uio_out,  // IOs: Output path
//     output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
//     input  wire       ena,      // always 1 when the design is powered, so you can ignore it
//     input  wire       clk,      // clock
//     input  wire       rst_n     // reset_n - low to reset
// );

//   // All output pins must be assigned. If not used, assign to 0.
//   assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
//   assign uio_out = 0;
//   assign uio_oe  = 0;

//   // List all unused inputs to prevent warnings
//   wire _unused = &{ena, clk, rst_n, 1'b0};

// endmodule

module tt_um_contador_bcd_3 (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

assign uio_oe = 8'hFF;
assign uio_out[7:4] = 4'h0;
assign uo_out[7] = 1'b0;

wire [6:0] cable_segmentos;
wire [3:0] cable_anodos;

assign uo_out[6:0] = cable_segmentos;
assign uio_out[3:0] = cable_anodos;

contador_bcd_3 contador_bcd_3_Unit (
    .clk(clk),
    .rst_n(rst_n),
    .salida_seg(cable_segmentos),
    .salida_an(cable_anodos)
);

    wire _unused = &{ui_in, uio_in, ena, 1'b0};

endmodule


