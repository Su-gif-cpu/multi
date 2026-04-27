`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/25 09:52:17
// Design Name: 
// Module Name: MUX_3to1_LMD
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "ctrl_signal_def.v"
module MUX_3to1_LMD(X, ALU_result_bypass, Y, Z, control, out);
    input [31:0] X;                 // 弃用
    input [31:0] ALU_result_bypass; // 使用实时信号
    input [31:0] Y;
    input [31:0] Z;
    input [1:0] control;
    output reg [31:0] out;

    always @ (*) begin
        case(control)
            2'b00 : out = ALU_result_bypass;
            2'b01 : out = Y;
            2'b10 : out = Z;
            2'b11 : out = 0;
        endcase
    end
endmodule
