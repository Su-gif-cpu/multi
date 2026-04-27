`include "ctrl_signal_def.v"

module MUX_2to1_A(X, RD1_bypass, Y, control, out);
    input [31:0] X;           // 弃用
    input [31:0] RD1_bypass;  // 使用实时信号
    input [4:0] Y;
    input control;
    output [31:0] out;
    assign out = (control == 1'b0 ? RD1_bypass : {27'b0,Y[4:0]});
endmodule