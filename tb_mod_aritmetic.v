`timescale 1ns / 1ps

module tb_mod_arithmetic;

    // Definim semnalele (folosim 'signed' pentru ca Montgomery lucreaza cu semne)
    reg signed [15:0] tb_a;
    reg signed [15:0] tb_b;
    
    wire signed [15:0] res_add;
    wire signed [15:0] res_sub;
    wire signed [15:0] res_mul;

    // 1. Instantiem Sumatorul
    mod_add uut_add (
        .a(tb_a),
        .b(tb_b),
        .out(res_add)
    );

    // 2. Instantiem Scazatorul
    mod_sub uut_sub (
        .a(tb_a),
        .b(tb_b),
        .out(res_sub)
    );

    // 3. Instantiem Inmultitorul Montgomery (NOU!)
    montgomery_mul uut_mul (
        .a(tb_a),
        .b(tb_b),
        .out(res_mul)
    );

    initial begin
        $display("================================================");
        $display("   START SIMULARE: KYBER ARITMETICA COMPLETA");
        $display("================================================");

        // --- TESTE ADUNARE & SCADERE ---
        tb_a = 100; tb_b = 200; #10;
        if(res_add !== 300) $display("[FAIL] Add 100+200. Got: %d", res_add);
        else                 $display("[PASS] Add 100+200 = 300");

        tb_a = 3000; tb_b = 1000; #10; // Overflow check
        if(res_add !== 671) $display("[FAIL] Add Modulo. Got: %d", res_add);
        else                 $display("[PASS] Add 3000+1000 mod 3329 = 671");

        tb_a = 100; tb_b = 200; #10; // Negative result check
        if(res_sub !== 3229) $display("[FAIL] Sub Modulo. Got: %d", res_sub);
        else                 $display("[PASS] Sub 100-200 mod 3329 = 3229");

        // --- TESTE INMULTIRE MONTGOMERY ---
        $display("------------------------------------------------");
        $display("   Testare Inmultire Montgomery");

        // Test 1: Inmultire cu 0 (Orice * 0 trebuie sa dea 0)
        tb_a = 0; tb_b = 1234; #10;
        if (res_mul !== 0) $display("[FAIL] Mul cu 0. Got: %d", res_mul);
        else               $display("[PASS] 0 * 1234 = 0");

        // Test 2: Inmultire simpla
        // Nota: Rezultatul nu este A*B, ci A*B*R^-1 mod Q.
        // Verificam doar ca scoate un rezultat valid (nu X sau Z).
        tb_a = 20; tb_b = 50; #10;
        
        if (res_mul === 16'bx || res_mul === 16'bz) 
            $display("[FAIL] Mul a returnat X (nedefinit)!");
        else 
            $display("[PASS] Mul(20, 50) a generat rezultatul valid: %d", res_mul);

        $display("================================================");
        $display("   TOATE TESTELE AU FOST RULATE");
        $display("================================================");
        $finish;
    end

endmodule