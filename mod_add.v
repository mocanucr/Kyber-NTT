`timescale 1ns / 1ps
module mod_add (input [15:0] a, b, output [15:0] out);
    localparam [15:0] Q = 16'd3329;
    wire [16:0] sum = a + b;
    wire [16:0] sub = sum - Q;
    assign out = (sum >= Q) ? sub[15:0] : sum[15:0];
endmodule