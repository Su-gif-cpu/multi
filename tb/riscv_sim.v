`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
// 
// Create Date: 2024/11/27 10:58:52
// Design Name:
// Module Name: riscv_sim
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
`timescale 1 ps / 1 ps

module riscv_sim ();
    // Inputs
    reg clk, rst;

    riscv U_RISCV(
        .clk(clk), .rst(rst)
    );

    initial begin
        $readmemh( "../hex/code.hex" ,U_RISCV.U_IM.memory) ;  //将指令送入指令存储器
        $display("Instruction memory initialized");
        $monitor("PC = 0x%8X, IR = 0x%8X",U_RISCV.U_PC.PC, U_RISCV.out_ins );
        clk = 1 ;

        #5 ;      //5个时延单位后
        rst = 1 ;
        #20 ;     //20个时延单位后
        rst = 0 ;
    end

    always
        #(50) clk = ~clk;

    initial begin
        $fsdbDumpvars(0,"riscv_sim"); //记录设计波形
        $fsdbDumpMDA(0,"riscv_sim");  //记录设计中数组的波形
    end

endmodule