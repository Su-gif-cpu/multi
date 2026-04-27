// 用于临时存储指令的二进制形式
`include "ctrl_signal_def.v"
module IR(in_ins, clk, IRWrite, out_ins);
    input clk, IRWrite;
    input [31:0] in_ins;
    output [31:0] out_ins;
    // 直接将IM输出的指令送给后面的译码和寄存器，彻底消除1拍延迟
    assign out_ins = in_ins; 
endmodule