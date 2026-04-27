`include "ctrl_signal_def.v"
module MUX_3to1_B(X, RD2_bypass, Y, Z, control, out);
    input [31:0] X;           // 弃用
    input [31:0] RD2_bypass;  // 使用实时信号
    input [31:0] Y;
    input [11:0] Z;
    input [1:0] control;
    output reg signed [31:0] out;

    always @ (*) begin
        case(control)
            2'b00 : out = RD2_bypass;
            2'b01 : out = Y;
            2'b10 : out = {{20{Z[11]}}, Z}; // 顺手保留之前修复的符号扩展
            2'b11 : out = RD2_bypass;
        endcase
    end
endmodule