`timescale 1ns/1ps
//Company:
//Engineer:
//
// Create Date: 2024/11/20 19:50:15
// Design Name:
// Module Name: instruction_def
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

//定义11条指令的OPCODE/FUNCT域。
//OPCODE域定义
`define INSTR_RTYPE_OP    7'b0110011  //R类型指令的OPCODE
`define INSTR_ITYPE_OP    7'b0010011  //I类型指令的OPCODE
`define INSTR_BTYPE_OP    7'b1100011  //B类型指令的OPCODE
`define INSTR_LW_OP       7'b0000011  //LW(加载字)指令的OPCODE
`define INSTR_SW_OP       7'b0100011  //SW(存储字)指令的OPCODE
`define INSTR_JAL_OP      7'b1101111  //JAL(跳转并链接)指令的OPCODE
`define INSTR_JALR_OP     7'b1100111  //JALR(跳转并链接)(寄存器版)指令的OPCODE

//R类型Funct域定义
`define INSTR_ADD_FUNCT   10'b0000000_000  //ADD指令的Funct
`define INSTR_SUB_FUNCT   10'b0100000_000  //SUB指令的Funct
`define INSTR_SUBU_FUNCT  6'b100011        //SUBU指令的Funct
`define INSTR_AND_FUNCT   10'b0000000_111   //AND指令的Funct
`define INSTR_OR_FUNCT    10'b0000000_110   //OR指令的Funct
`define INSTR_XOR_FUNCT   10'b0000000_100   //XOR指令的Funct
`define INSTR_NOR_FUNCT   6'b100111        //NOR指令的Funct
`define INSTR_SLL_FUNCT   10'b0000000_001   //SLL(逻辑左移)指令的Funct
`define INSTR_SRL_FUNCT   10'b0000000_101   //SRL(逻辑右移)指令的Funct
`define INSTR_SRA_FUNCT   10'b0100000_101   //SRA(算术右移)指令的Funct
`define INSTR_SRLV_FUNCT  6'b000110        //SRLV(可变逻辑右移)指令的Funct
`define INSTR_SRAV_FUNCT  6'b000111        //SRAV(可变算术右移)指令的Funct
`define INSTR_SLLV_FUNCT  6'b000100        //SLLV(可变逻辑左移)指令的Funct
`define INSTR_JR_FUNCT    6'b001000        //JR(寄存器跳转)指令的Funct

//B类型Funct域定义
`define INSTR_BEQ_FUNCT   3'b000  //BEQ指令的Funct
`define INSTR_BNE_FUNCT   3'b001  //BNE指令的Funct

//I类型 Funct域定义
`define INSTR_ADDI_FUNCT  3'b000  //ADDI指令的Funct
`define INSTR_ORI_FUNCT   3'b110  //ORI指令的Funct