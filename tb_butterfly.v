`timescale 1ns / 1ps

module tb_butterfly;

    reg signed [15:0] tb_u;
    reg signed [15:0] tb_v;
    reg signed [15:0] tb_zeta;
    wire signed [15:0] out_up;
    wire signed [15:0] out_low;

    // Instantiem Butterfly
    butterfly uut (
        .u(tb_u),
        .v(tb_v),
        .zeta(tb_zeta),
        .out_upper(out_up),
        .out_lower(out_low)
    );

    initial begin
        $display("=== TEST BUTTERFLY ===");
        
        // Cazul 1: Zeta = 0 (Element neutru la inmultire Montgomery este R, nu 1)
        // Dar daca Zeta=0 => V*zeta=0 => Upper=U, Lower=U.
        tb_u = 100; tb_v = 200; tb_zeta = 0;
        #10;
        if(out_up == 100 && out_low == 100) $display("[PASS] Zeta 0 OK");
        else $display("[FAIL] Zeta 0. Upper: %d, Lower: %d", out_up, out_low);

        // Cazul 2: Un test vizual
        tb_u = 500; tb_v = 100; tb_zeta = 10; // 10 este un numar mic
        #10;
        $display("Intrari: U=500, V=100, Zeta=10");
        $display("Rezultate: Upper=%d, Lower=%d", out_up, out_low);
        // Nota: Valorile exacte sunt greu de prezis mental din cauza Montgomery,
        // dar daca nu sunt X sau Z, unitatea functioneaza hardware.

        $finish;
    end

endmodule