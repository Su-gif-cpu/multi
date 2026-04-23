`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/25 19:48:14
// Design Name: 
// Module Name: PC
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
module PC(clk, rst, PCWrite, NPC, PC);
    input clk;              //时钟信号
    input rst;              //复位信号
    input PCWrite;          //PC写使能信号
    input [31:0] NPC;       //下条指令的地址
    output reg [31:0] PC;   //本条指令地址

    always @(posedge clk or posedge rst) begin
        // reset
        if (rst) begin
            PC <= 32'h0000_2000; //复位后PC的值
        end
        else if (PCWrite) begin
            PC <= NPC;           //修改指令地址
        end
    end
endmodule