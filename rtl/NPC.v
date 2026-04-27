`timescale 1ns / 1ps
`include "ctrl_signal_def.v"
`include "instruction_def.v"

module NPC(
    input [31:0] PC,
    input [1:0] NPCOp,
    input [12:1] Offset12,
    input [20:1] Offset20,
    input [31:0] rs,       // 顶层连接了 ALU_result
    output reg [31:0] PCA4,
    output reg [31:0] NPC
);
    wire signed [31:0] Offset13;
    wire signed [31:0] Offset21;
    
    // 修复1：正确的 Verilog 符号扩展语法，确保向后跳转（负数偏移）正确计算
    assign Offset13 = {{19{Offset12[12]}}, Offset12[12:1], 1'b0};
    assign Offset21 = {{11{Offset20[20]}}, Offset20[20:1], 1'b0};

    always @(*) begin
        case(NPCOp)
            // 顺序执行：下一条指令为当前 PC + 4
            `NPC_PC       : NPC = PC + 4; 
            
            // BEQ / BNE 分支跳转：因为当前PC没变，直接 PC + Offset
            `NPC_Offset12 : NPC = PC + Offset13; 
            
            // JALR 跳转寄存器：修复2 - RISC-V 规范要求 JALR 必须强行清零目标地址的最低位
            `NPC_rs       : NPC = {rs[31:1], 1'b0}; 
            
            // JAL 跳转并链接：同样当前PC没变，直接 PC + Offset
            `NPC_Offset20 : NPC = PC + Offset21; 
            
            default       : NPC = PC + 4;
        endcase
        
        // 用于 JAL / JALR 存回目标寄存器（通常是 ra/x1）的返回地址
        PCA4 = PC + 4; 
    end
endmodule