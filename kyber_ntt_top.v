`timescale 1ns / 1ps

module kyber_ntt_top (
    input wire clk,
    input wire rst,
    input wire start,           // Semnal de start
    output reg done,            // Semnal cand s-a terminat
    output wire [15:0] result_check // Iesire de debug (sa vedem ultimul rezultat)
);

    // --- Parametri ---
    localparam [15:0] ZETA_TEST = 16'd10; // Folosim o valoare fixa pt Zeta in acest test
    
    // --- Stari FSM (Finite State Machine) ---
    localparam STATE_IDLE  = 3'd0;
    localparam STATE_READ  = 3'd1;
    localparam STATE_WAIT  = 3'd2; // Memoria are nevoie de 1 ciclu sa raspunda
    localparam STATE_CALC  = 3'd3;
    localparam STATE_WRITE = 3'd4;
    localparam STATE_DONE  = 3'd5;

    reg [2:0] state;
    reg [7:0] counter; // Numara perechile procesate (0 pana la 127)

    // --- Semnale pentru Memorie ---
    reg  we_a, we_b;
    reg  [7:0] addr_a, addr_b;
    reg  [15:0] din_a, din_b;
    wire [15:0] dout_a, dout_b;

    // --- Semnale pentru Butterfly ---
    wire signed [15:0] bf_out_upper;
    wire signed [15:0] bf_out_lower;

    // --- 1. Instantiere MEMORIE RAM ---
    dual_port_ram #(.DATA_WIDTH(16), .ADDR_WIDTH(8)) memory (
        .clk(clk),
        .we_a(we_a), .addr_a(addr_a), .din_a(din_a), .dout_a(dout_a),
        .we_b(we_b), .addr_b(addr_b), .din_b(din_b), .dout_b(dout_b)
    );

    // --- 2. Instantiere BUTTERFLY Unit ---
    butterfly core_bf (
        .u(dout_a),      // Intrare U din portul A
        .v(dout_b),      // Intrare V din portul B
        .zeta(ZETA_TEST),
        .out_upper(bf_out_upper),
        .out_lower(bf_out_lower)
    );
    
    // Conectam iesirea de debug la portul A al memoriei
    assign result_check = dout_a;

    // --- 3. Logica de Control (FSM) ---
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= STATE_IDLE;
            counter <= 0;
            done <= 0;
            we_a <= 0; we_b <= 0;
            addr_a <= 0; addr_b <= 0;
        end else begin
            case (state)
                // STARE 0: Asteptam semnalul de START
                STATE_IDLE: begin
                    done <= 0;
                    counter <= 0;
                    if (start) state <= STATE_READ;
                end

                // STARE 1: Citim perechea (U, V) din memorie
                STATE_READ: begin
                    we_a <= 0; we_b <= 0; // Nu scriem, doar citim
                    // Procesam perechi: (0,1), (2,3), etc.
                    addr_a <= counter * 2;     // Adresa para (U)
                    addr_b <= counter * 2 + 1; // Adresa impara (V)
                    state <= STATE_WAIT;
                end

                // STARE 2: Asteptam RAM-ul (are latenta 1 ciclu)
                STATE_WAIT: begin
                    state <= STATE_CALC;
                end

                // STARE 3: Executam Butterfly (Hardware-ul e combination, se intampla instant)
                // Pregatim scrierea rezultatelor
                STATE_CALC: begin
                    // Datele dout_a si dout_b sunt valide acum.
                    // Butterfly-ul a calculat deja bf_out_upper/lower.
                    state <= STATE_WRITE;
                end

                // STARE 4: Scriem rezultatele inapoi in aceleasi locatii
                STATE_WRITE: begin
                    we_a <= 1; 
                    din_a <= bf_out_upper; // Scriem U + V*zeta
                    
                    we_b <= 1;
                    din_b <= bf_out_lower; // Scriem U - V*zeta
                    
                    // Verificam daca am terminat toate cele 128 de perechi
                    if (counter == 127) begin
                        state <= STATE_DONE;
                    end else begin
                        counter <= counter + 1; // Trecem la urmatoarea pereche
                        state <= STATE_READ;
                    end
                end

                // STARE 5: Final
                STATE_DONE: begin
                    done <= 1;
                    we_a <= 0; we_b <= 0; // Oprim scrierea
                    state <= STATE_IDLE;  // Ne intoarcem la inceput
                end
            endcase
        end
    end

endmodule