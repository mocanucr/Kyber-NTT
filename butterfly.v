`timescale 1ns / 1ps

module butterfly (
    input  wire signed [15:0] u,
    input  wire signed [15:0] v,
    input  wire signed [15:0] zeta, // Factorul de "twiddle"
    output wire signed [15:0] out_upper, // U + V*zeta
    output wire signed [15:0] out_lower  // U - V*zeta
);

    // Firul care tine rezultatul inmultirii V * zeta
    wire signed [15:0] v_times_zeta;

    // 1. Calculam V * zeta folosind Inmultitorul Montgomery
    montgomery_mul unit_mul (
        .a(v),
        .b(zeta),
        .out(v_times_zeta)
    );

    // 2. Calculam U + (V*zeta)
    mod_add unit_add (
        .a(u),
        .b(v_times_zeta),
        .out(out_upper)
    );

    // 3. Calculam U - (V*zeta)
    mod_sub unit_sub (
        .a(u),
        .b(v_times_zeta),
        .out(out_lower)
    );

endmodule