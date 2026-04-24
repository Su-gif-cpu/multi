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

module riscv_sim ();
    // Inputs
    reg clk, rst;

    // Instantiate the DUT
    riscv U_RISCV(
        .clk(clk), .rst(rst)
    );

    // Initialization and Reset
    initial begin
        $readmemh("../hex/code.hex", U_RISCV.U_IM.memory);  // 将指令送入指令存储器
        $display("Instruction memory initialized");
        $monitor("Time: %0t | PC = 0x%8X, IR = 0x%8X", $time, U_RISCV.U_PC.PC, U_RISCV.out_ins);
        
        clk = 1;
        #5;       // 5个时延单位后
        rst = 1;
        #20;      // 20个时延单位后
        rst = 0;
    end

    // Clock Generation (周期为 100ns)
    always #(50) clk = ~clk;

    // ========================================================
    // 自动监控和判定测试结果 (基于 PC 起始 0x2000 以及 x[30] 判定)
    // ========================================================
    reg test_failed = 0;
    
    // 超时保险：防止程序死循环跑不出来
    initial begin
        #50000; 
        $display("\n=============================================");
        $display("  [TIMEOUT] Simulation Timeout! ");
        $display("  Program stuck in infinite loop or failed to reach end.");
        $display("=============================================\n");
        $finish;
    end

    // 结果判定逻辑 (纯同步监控，不使用 # 延时)
    always @(posedge clk) begin
        if (rst == 0) begin
            
            // ----------------------------------------------------
            // 监控 1：判断 beq 跳转是否失败（PC 掉入了被跳过的 0x2088 区域）
            // ----------------------------------------------------
            if (U_RISCV.U_PC.PC == 32'h00002088) begin
                test_failed = 1;
            end
            
            // ----------------------------------------------------
            // 监控 2：终极胜利条件，x30 成功被写入了 0xAB
            // ----------------------------------------------------
            if (U_RISCV.U_RF.register[30] == 32'h000000ab) begin
                $display("\n=============================================");
                $display("  [SUCCESS] Simulation Passed! ");
                $display("  Target x[30] == 0xAB has been achieved!");
                $display("  Final PC = 0x%8X", U_RISCV.U_PC.PC);
                $display("=============================================\n");
                $finish;
            end
            
            // ----------------------------------------------------
            // 监控 3：如果 PC 跑到了 0x20A0 (距离最后的lw指令已经过去了多条指令)
            // 这说明流水线/多周期已经完全结束，但 x30 还不是 0xAB，则判定失败
            // ----------------------------------------------------
            if (U_RISCV.U_PC.PC == 32'h000020A0) begin
                if (U_RISCV.U_RF.register[30] != 32'h000000ab) begin
                    $display("\n=============================================");
                    $display("  [FAILED] Simulation Failed! ");
                    if (test_failed == 1)
                        $display("  Reason: Branch 'beq' failed. PC hit 0x2088.");
                    else
                        $display("  Reason: PC reached end, but x[30] != 0xAB (Current x[30] = 0x%8X).", U_RISCV.U_RF.register[30]);
                    $display("=============================================\n");
                    $finish;
                end
            end
            
        end
    end

    // ========================================================
    // Verdi 波形导出 (FSDB)
    // ========================================================
    initial begin
        $fsdbDumpvars(0, "riscv_sim"); // 记录设计波形
        $fsdbDumpMDA(0, "riscv_sim");  // 记录设计中数组(寄存器/内存)的波形，必须有这个才能看 x0-x31
    end

endmodule