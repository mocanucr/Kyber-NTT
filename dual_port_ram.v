`timescale 1ns / 1ps

module dual_port_ram #(
    parameter DATA_WIDTH = 16,  // 16 biti per coeficient
    parameter ADDR_WIDTH = 8    // 2^8 = 256 locatii
)(
    input wire clk,
    
    // Port A (pentru operatiile pe 'U')
    input wire we_a,                  // Write Enable A
    input wire [ADDR_WIDTH-1:0] addr_a,
    input wire [DATA_WIDTH-1:0] din_a,
    output reg [DATA_WIDTH-1:0] dout_a,

    // Port B (pentru operatiile pe 'V')
    input wire we_b,                  // Write Enable B
    input wire [ADDR_WIDTH-1:0] addr_b,
    input wire [DATA_WIDTH-1:0] din_b,
    output reg [DATA_WIDTH-1:0] dout_b
);

    // Definim memoria propriu-zisa (256 x 16 biti)
    // Vivado va recunoaste automat ca asta este BRAM
    reg [DATA_WIDTH-1:0] ram [0:(2**ADDR_WIDTH)-1];

    // Operatiile pe Portul A
    always @(posedge clk) begin
        if (we_a) begin
            ram[addr_a] <= din_a;
        end
        dout_a <= ram[addr_a];
    end

    // Operatiile pe Portul B
    always @(posedge clk) begin
        if (we_b) begin
            ram[addr_b] <= din_b;
        end
        dout_b <= ram[addr_b];
    end

    // Initializare (Optional, util pt simulare ca sa nu avem 'X')
    integer i;
    initial begin
        for (i=0; i<256; i=i+1) ram[i] = 0;
    end

endmodule