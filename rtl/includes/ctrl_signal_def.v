//相关控制信号的宏。其中使用Verilog描述控制器的控制信号时，需与该宏保持一致。
//也可根据情况增加控制信号的宏。

//NPC control signal
`define NPC_PC         2'b00
`define NPC_Offset12   2'b01
`define NPC_rs         2'b10
`define NPC_Offset20   2'b11

//A control signal
`define ALUSrcA_A      1'b0
`define ALUSrcA_sa     1'b1

//B control signal
`define ALUSrcB_B       2'b00
`define ALUSrcB_Imm     2'b01
`define ALUSrcB_Offset  2'b10
`define ALUSrcB_else    2'b11

//EXT control signal
`define ExtSel_ZERO    1'b0
`define ExtSel_SIGNED  1'b1

//ALU control signal
`define ALUOp_ADD    4'b0000  //加法
`define ALUOp_SUB    4'b0001  //减法
`define ALUOp_AND    4'b0010  //按位与
`define ALUOp_OR     4'b0011  //按位或
`define ALUOp_XOR    4'b0100  //按位异或
`define ALUOp_SRA    4'b0111  //算数右移
`define ALUOp_SLL    4'b1000  //逻辑左移
`define ALUOp_SRL    4'b1001  //逻辑右移
`define ALUOp_BR     4'b1010  //比较相等

//RF control signal
`define RegSel_rd     2'b00
`define RegSel_rt     2'b01
`define RegSel_31     2'b10
`define RegSel_else   2'b11

`define WDSel_FromALU  2'b00
`define WDSel_FromMEM  2'b01
`define WDSel_FromPC   2'b10
`define WDSel_Else     2'b11

//DM control signal
`define DMCtrl_RD  1'b0
`define DMCtrl_WR  1'b1