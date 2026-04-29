`timescale 1ns / 1ps
`include "ctrl_signal_def.v"

`timescale 1ns / 1ps

module DM( Addr, Addr_bypass, WD, WD_bypass, clk, DMCtrl, RD);
    input [11:2] Addr;
    input [11:2] Addr_bypass;
    input [31:0] WD;
    input [31:0] WD_bypass;
    input clk;
    input [1:0] DMCtrl;
    output reg [31:0] RD;

    reg [31:0] memory[0:1023];

    always @(posedge clk) begin
        if (DMCtrl == 2'b10) begin
            memory[Addr_bypass] <= WD_bypass; 
            $display("[DM READ]  Time: %0t | Addr: %0d | Data: %h", $time, Addr_bypass, memory[Addr_bypass]);
        end
    end
endmodule