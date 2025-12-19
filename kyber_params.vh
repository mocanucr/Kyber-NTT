`ifndef KYBER_PARAMS_VH
`define KYBER_PARAMS_VH

// Parametrii specifici Kyber
// q = 3329 (numar prim). 
// Folosim 16 biti pentru stocare (2^12 = 4096 > 3329).
localparam [15:0] KYBER_Q = 16'd3329;
localparam integer DATA_W = 16;

`endif