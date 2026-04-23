`include "ctrl_signal_def.v"
module MUX_3to1_B(X, Y, Z, control, out);
    input [31:0] X;     //临时寄存器B中的内容
    input [31:0] Y;     //临时寄存器Imm中的内容
    input [11:0] Z;     //临时寄存器Offset中的内容
    input [1:0] control;        //选择控制信号
    output reg signed [31:0] out; //输出选择结果

    always @ (X or Y or Z or control) begin
        case(control)
            `ALUSrcB_B      : out = X;                          //选择X
            `ALUSrcB_Imm    : out = Y;                          //选择Y
            `ALUSrcB_Offset : out = {{20{Z[11]}}, Z};           //Bug M1 修复：正确的符号扩展
            `ALUSrcB_else   : out = X;                          //选择X
        endcase
    end

endmodule