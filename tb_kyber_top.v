`timescale 1ns / 1ps

module tb_kyber_top;

    reg clk;
    reg rst;
    reg start;
    wire done;
    wire [15:0] result_debug;

    // Instantiem Top Module
    kyber_ntt_top uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done),
        .result_check(result_debug)
    );

    // Generator de ceas (Clock 10ns = 100MHz)
    always #5 clk = ~clk;

    initial begin
        // Setup initial
        clk = 0;
        rst = 1;
        start = 0;
        
        // --- Pasul 1: Initializam memoria cu valori de test ---
        // Hack: Scriem direct in memoria interna a instantei pentru test
        // UUT.memory.ram[0] = 100 (U)
        // UUT.memory.ram[1] = 200 (V)
        uut.memory.ram[0] = 16'd100;
        uut.memory.ram[1] = 16'd200;
        
        $display("=== START SISTEM COMPLET KYBER ===");
        $display("Memorie Initiala [0]: %d", uut.memory.ram[0]);
        $display("Memorie Initiala [1]: %d", uut.memory.ram[1]);

        // --- Pasul 2: Reset si Start ---
        #20;
        rst = 0;
        #10;
        start = 1; // Pornim acceleratorul
        #10;
        start = 0;

        // --- Pasul 3: Asteptam sa termine ---
        wait(done == 1);
        
        // --- Pasul 4: Verificam rezultatele ---
        #20;
        $display("----------------------------------");
        $display("Procesare terminata!");
        $display("Memorie Finala [0] (Upper): %d", uut.memory.ram[0]);
        $display("Memorie Finala [1] (Lower): %d", uut.memory.ram[1]);
        
        // Verificare logica:
        // Butterfly face: U +/- V*zeta. 
        // Daca memoria s-a schimbat fata de 100/200, sistemul functioneaza!
        if (uut.memory.ram[0] !== 100) 
            $display("[SUCCESS] Memoria a fost actualizata de FPGA!");
        else 
            $display("[FAIL] Memoria a ramas neschimbata.");

        $finish;
    end

endmodule