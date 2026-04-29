`include "global_def.v"
`include "ctrl_signal_def.v"

module RF(
    input [4:0] RR1,        // 读取寄存器1地址
    input [4:0] RR2,        // 读取寄存器2地址
    input [4:0] WR,         // 写入寄存器地址
    input [31:0] WD,        // 写入数据
    input RFWrite,          // 寄存器写使能信号
    input clk,              // 时钟信号
    output [31:0] RD1,      // 读取寄存器1数据
    output [31:0] RD2       // 读取寄存器2数据
);

    reg [31:0] register [1:31]; // 31个32位寄存器

    //  r0 不需要分配寄存器，直接用线网表示即可
    wire [31:0] r0 = 32'h0000_0000;

    // Bug RF1 修复：x0 每周期强制清零
    always @(posedge clk) begin
        // 在上升沿时钟信号时，如果写入寄存器地址不为0且写使能信号为1，则写入数据到指定寄存器
        if ((WR != 0) && (RFWrite == 1)) begin
            register[WR] <= WD;
            `ifdef DEBUG
                // 如果定义了DEBUG宏，则输出寄存器的值
                $display("R[00-07]=%8X %8X %8X %8X %8X %8X %8X %8X", 0, register[1], register[2], register[3], register[4], register[5], register[6], register[7]);
                $display("R[08-15]=%8X %8X %8X %8X %8X %8X %8X %8X", register[8], register[9], register[10], register[11], register[12], register[13], register[14], register[15]);
                $display("R[16-23]=%8X %8X %8X %8X %8X %8X %8X %8X", register[16], register[17], register[18], register[19], register[20], register[21], register[22], register[23]);
                $display("R[24-31]=%8X %8X %8X %8X %8X %8X %8X %8X", register[24], register[25], register[26], register[27], register[28], register[29], register[30], register[31]);
            `endif
        end
    end

    // 异步读：如果地址是0，直接返回硬连线的 r0 (全0)；否则从数组读取
    assign RD1 = (RR1 == 5'd0) ? r0 : register[RR1];
    assign RD2 = (RR2 == 5'd0) ? r0 : register[RR2];

endmodule