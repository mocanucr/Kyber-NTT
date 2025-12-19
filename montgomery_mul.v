`timescale 1ns / 1ps

module montgomery_mul (
    input  wire signed [15:0] a,
    input  wire signed [15:0] b,
    output wire signed [15:0] out
);
    // Include parametrii (Q = 3329)
    `include "kyber_params.vh"

    // Constanta Montgomery pentru Q=3329: 
    // Qprime = -Q^(-1) mod 2^16 = 3327
    localparam signed [15:0] QPRIME = 16'd3327;

    // Variabile interne
    wire signed [31:0] product;
    wire signed [15:0] k;
    wire signed [31:0] m;
    wire signed [15:0] t;
    wire signed [15:0] res;

    // Pasul 1: Inmultirea normala (rezultat pe 32 biti)
    assign product = a * b;

    // Pasul 2: Reducerea Montgomery
    // Formula: t = (product - (product * Q' mod R) * Q) / R
    
    // a) Calculam factorul k = product * Q' mod 2^16
    // (Luam doar cei 16 biti de jos, deci e automat mod 2^16)
    assign k = product * QPRIME;

    // b) Calculam m = k * Q
    assign m = k * KYBER_Q;

    // c) Calculam t = (product - m) / 2^16
    // In hardware, impartirea la 2^16 este doar o shiftare la dreapta (>>> 16)
    // Sau pur si simplu luam bitii de sus [31:16]
    wire signed [31:0] temp_sub;
    assign temp_sub = product - m;
    
    assign t = temp_sub[31:16]; 

    // Pasul 3: Corectia finala
    // Rezultatul t poate fi negativ sau >= Q, trebuie adus in intervalul [0, Q-1]
    // Deoarece lucram cu numere signed, verificam daca e negativ.
    // Daca t < 0, adaugam Q. Altfel ramane t.
    // Nota: Algoritmul garanteaza ca t e in intervalul (-Q, Q).
    assign out = (t < 0) ? (t + KYBER_Q) : t;

endmodule