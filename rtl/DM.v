`include "ctrl_signal_def.v"
module DM( Addr, Addr_bypass, WD, WD_bypass, clk, DMCtrl, RD);
    input [11:2] Addr;          // 弃用
    input [11:2] Addr_bypass;   // 实时的ALU地址
    input [31:0] WD;            // 弃用
    input [31:0] WD_bypass;     // 实时的要写入的数据(RD2)
    input clk;
    input [1:0] DMCtrl;
    output reg [31:0] RD;

    reg [31:0] memory[0:1023];

    always @(posedge clk) begin
        if (DMCtrl == 2'b10) memory[Addr_bypass] <= WD_bypass; // 同步写
        if (DMCtrl == 2'b01) RD <= memory[Addr_bypass];        // 同步读
    end
endmodule