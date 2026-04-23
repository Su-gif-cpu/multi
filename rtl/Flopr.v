`include "ctrl_signal_def.v"
module Flopr(clk, rst, in_data, out_data );
    input clk;                      //时钟信号
    input rst;                      //复位信号
    input [31:0] in_data;           //输入的数据
    output reg [31:0] out_data;     //输出的数据

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            out_data <= 0;          //复位后，输出为0
        end
        else begin
            out_data <= in_data;    //将输入数据输出
        end
    end
endmodule