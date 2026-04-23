`include "ctrl_signal_def.v"
module DM( Addr, WD, clk, DMCtrl, RD);
    input  [11:2] Addr;             //读写对应的地址
    input  [31:0] WD;               //写入的数据
    input  clk;                     //时钟信号
    input DMCtrl;                   //读写控制信号
    output reg [31:0] RD;           //读出的数据

    reg [31:0] memory[0:1023];

    // 修改为同步读写（SRAM宏替换准备）
    always @(posedge clk) begin
        if (DMCtrl) begin
            memory[Addr] <= WD;     //同步写入数据
        end
        RD <= memory[Addr];         //同步读出数据
    end

endmodule