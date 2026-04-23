`include "ctrl_signal_def.v"
module MUX_2to1_A(X, Y, control, out);
    input [31:0] X;             //临时寄存器A中的内容
    input [4:0] Y;              //预留输入
    input control;              //选择控制信号
    output [31:0] out;          //输出选择结果

    assign out = (control == 1'b0 ? X : {27'b0,Y[4:0]});

endmodule