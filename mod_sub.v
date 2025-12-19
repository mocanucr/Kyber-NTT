`timescale 1ns / 1ps
module mod_sub (input [15:0] a, b, output [15:0] out);
    localparam [15:0] Q = 16'd3329;
    wire [16:0] diff = a - b;
    wire [16:0] add = diff + Q;
    assign out = (a >= b) ? diff[15:0] : add[15:0];
endmodule