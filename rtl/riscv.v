`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2024/11/22 13:30:25
// Design Name:
// Module Name: riscv
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
`include "instruction_def.v"

module riscv(clk, rst);
    input clk, rst;

    wire RFWrite, DMCtrl, PCWrite, IRWrite, InsMemRW, ExtSel, zero, ALUSrcA;
    wire [1:0] ALUSrcB;
    wire [1:0] NPCOp, WDSel, RegSel;
    wire [3:0] ALUOp;
    wire [6:0] opcode;
    wire [2:0] Funct3;
    wire [6:0] Funct7;
    wire [31:0] PC, NPC, PCA4;
    wire [31:0] in_ins, out_ins, RD, DR_out;
    wire [4:0] rs1, rs2, rd;
    wire [11:0] Imm12;
    wire [31:0] Imm32;
    wire [20:1] Offset20;
    wire [11:0] Offset;
    wire [4:0] WR;
    wire [31:0] WD;
    wire [31:0] RD1, RD1_r, RD2, RD2_r;
    wire [31:0] A, B, ALU_result, ALU_result_r;

    assign opcode = out_ins[6:0];
    assign Funct3 = out_ins[14:12];
    assign Funct7 = out_ins[31:25];
    assign rs1    = out_ins[19:15];
    assign rs2    = out_ins[24:20];
    assign rd     = out_ins[11:7];

    assign Imm12    = out_ins[31:20];
    assign Offset20 = {out_ins[31],out_ins[19:12],out_ins[20],out_ins[30:21]};
    assign Offset   = (opcode == `INSTR_BTYPE_OP) ? {out_ins[31],out_ins[7],out_ins[30:25],out_ins[11:8]} : 
                      (opcode == `INSTR_SW_OP)    ? {out_ins[31:25],out_ins[11:7]}                       : Imm12;

    // 实例化 ControlUnit
    ControlUnit U_ControlUnit(
        .clk(clk), .rst(rst), .zero(zero), .opcode(opcode), .Funct7(Funct7), .Funct3(Funct3),
        .RFWrite(RFWrite), .DMCtrl(DMCtrl), .PCWrite(PCWrite), .IRWrite(IRWrite), .InsMemRW(InsMemRW),
        .ExtSel(ExtSel), .ALUOp(ALUOp), .NPCOp(NPCOp), .ALUSrcA(ALUSrcA),
        .WDSel(WDSel), .ALUSrcB(ALUSrcB), .RegSel(RegSel)
    );

    // 实例化 PC
    PC U_PC (
        .clk(clk), .rst(rst), .PCWrite(PCWrite), .NPC(NPC), .PC(PC)
    );

    // 实例化 NPC
    NPC U_NPC (
        .PC(PC), .NPCOp(NPCOp), .Offset12(Offset), .Offset20(Offset20), .rs(ALU_result), .PCA4(PCA4), .NPC(NPC)
    );

    // 实例化 IM
    IM U_IM (
        .addr(PC[11:2]), .Ins(in_ins), .InsMemRW(InsMemRW), .clk(clk)
    );

    // 实例化 IR
    IR U_IR (
        .clk(clk), .IRWrite(IRWrite), .in_ins(in_ins), .out_ins(out_ins)
    );

    // 实例化 RF
    RF U_RF (
        .RR1(rs1), .RR2(rs2), .WR(WR), .WD(WD), .clk(clk),
        .RFWrite(RFWrite), .RD1(RD1), .RD2(RD2)
    );

    // 实例化 MUX_3to1
    MUX_3to1 U_MUX_3to1 (
        .X(rd), .Y(5'd0), .Z(5'd31),
        .control(RegSel), .out(WR)
    );

    // 实例化 MUX_3to1_LMD （新增 ALU_result_bypass）
    MUX_3to1_LMD U_MUX_3to1_LMD (
        .X(ALU_result_r), .ALU_result_bypass(ALU_result), .Y(DR_out), .Z(PCA4),
        .control(WDSel), .out(WD)
    );

    // 实例化 Flopr
    Flopr U_A (
        .clk(clk), .rst(rst), .in_data(RD1), .out_data(RD1_r)
    );

    // 实例化 Flopr
    Flopr U_B (
        .clk(clk), .rst(rst), .in_data(RD2), .out_data(RD2_r)
    );

    // 实例化 EXT
    EXT U_EXT (
        .imm_in(Imm12), .ExtSel(ExtSel), .imm_out(Imm32)
    );

    // 实例化 MUX_2to1_A （新增 RD1_bypass）
    MUX_2to1_A U_MUX_2to1_A (
        .X(RD1_r), .RD1_bypass(RD1), .Y(32'h0), .control(ALUSrcA), .out(A)
    );

    // 实例化 MUX_3to1_B （新增 RD2_bypass）
    MUX_3to1_B U_MUX_3to1_B (
        .X(RD2_r), .RD2_bypass(RD2), .Y(Imm32), .Z(Offset), .control(ALUSrcB), .out(B)
    );

    // 实例化 ALU
    ALU U_ALU (
        .A(A), .B(B), .ALUOp(ALUOp), .ALU_result(ALU_result), .zero(zero)
    );

    // 实例化 Flopr
    Flopr U_ALUOut (
        .clk(clk), .rst(rst), .in_data(ALU_result), .out_data(ALU_result_r)
    );

    // 实例化 DM （新增 Addr_bypass 和 WD_bypass）
    DM U_DM (
        .Addr(ALU_result_r[11:2]), .Addr_bypass(ALU_result[11:2]), 
        .WD(RD2_r), .WD_bypass(RD2), 
        .DMCtrl(DMCtrl), .clk(clk), .RD(RD)
    );

    //// 实例化 Flopr
    //Flopr U_DR (
    //    .clk(clk), .rst(rst), .in_data(RD), .out_data(DR_out)
    //);

    assign DR_out = RD;
endmodule