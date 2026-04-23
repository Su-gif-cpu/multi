`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2024/11/27 10:58:52
// Design Name:
// Module Name: r_type_sim
// Project Name:
// Target Devices:
// Tool Versions:
// Description: Testbench for R-type instructions
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1 ps / 1 ps

module r_type_sim ();
    // Inputs
    reg clk, rst;

    riscv U_RISCV(
        .clk(clk), .rst(rst)
    );

    initial begin
        $readmemh( "../hex/r_type_test.hex" ,U_RISCV.U_IM.memory) ;  //将指令送入指令存储器
        $display("R-type test instruction memory initialized");
        $monitor("PC = 0x%8X, IR = 0x%8X",U_RISCV.U_PC.PC, U_RISCV.out_ins );
        clk = 1 ;

        #5 ;      //5个时延单位后
        rst = 1 ;
        #20 ;     //20个时延单位后
        rst = 0 ;

        // Run for a limited time to test R-type instructions
        #10000 ;  // Adjust time as needed for simulation
        $finish;
    end

    always
        #(50) clk = ~clk;

    initial begin
        $fsdbDumpvars(0,"r_type_sim"); //记录设计波形
        $fsdbDumpMDA(0,"r_type_sim");  //记录设计中数组的波形
    end

endmodule