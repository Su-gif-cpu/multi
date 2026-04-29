`timescale 1ns / 1ps

module riscv_sim ();
    // ========================================================
    // 复位 PC 地址
    // ========================================================
    parameter PC_BASE = 32'h00002000; 

    // Inputs
    reg clk, rst;
    integer i;

    // Instantiate the DUT
    riscv U_RISCV(
        .clk(clk), .rst(rst)
    );

    // Initialization and Reset
    initial begin
        // 初始化寄存器
        for (i = 1; i < 32; i = i + 1) begin
            U_RISCV.U_RF.register[i] = 32'h0;
        end

        // 初始化数据存储器
        for (i = 0; i < 1024; i = i + 1) begin
          U_RISCV.U_DM.memory[i] = 32'h0;
        end
        
        // 载入正确的 Hex 机器码
        // 请确保你的指令存储器(U_IM)取指逻辑类似： instruction = memory[(PC - 32'h2000) >> 2];
        $readmemh("../hex/code.hex", U_RISCV.U_IM.memory);  
        $display("Instruction memory initialized. CPU PC starts at 0x%8X", PC_BASE);
        $monitor("Time: %0t | PC = 0x%8X, IR = 0x%8X", $time, U_RISCV.U_PC.PC, U_RISCV.out_ins);
        
        clk = 1;
        #5;       
        rst = 1;
        #20;      
        rst = 0;
    end

    // Clock Generation (周期为 100ns)
    always #(50) clk = ~clk;

    // ========================================================
    // IPC 监测与统计变量
    // ========================================================
    integer total_cycles = 0;   // 总运行时钟周期
    integer total_instrs = 0;   // 总执行指令数
    real    ipc_value    = 0.0; // IPC 浮点结果

    // ========================================================
    // 错误标志寄存器
    // ========================================================
    reg test_failed_beq = 0;
    reg test_failed_jalr_skip = 0;
    
    // 超时保险
    initial begin
        #1000000; 
        $display("\n=============================================");
        $display("  [TIMEOUT] Simulation Timeout! ");
        if (total_cycles > 0) ipc_value = $itor(total_instrs) / $itor(total_cycles);
        $display("  Current IPC        : %0.3f", ipc_value);
        $display("=============================================\n");
        $finish;
    end

    // 结果判定逻辑
    always @(posedge clk) begin
        if (rst == 0) begin
            // 统计周期与指令数 (假设 PCWrite 高电平时更新PC，即指令完成)
            total_cycles = total_cycles + 1;
            if (U_RISCV.PCWrite == 1'b1) begin
                total_instrs = total_instrs + 1;
            end

            // ----------------------------------------------------
            // 监控 1：判断 beq 跳转是否失败（PC 是否掉入了偏移 0x88 区域）
            // ----------------------------------------------------
            if (U_RISCV.U_PC.PC == (PC_BASE + 32'h00000088)) begin
                test_failed_beq = 1;
            end
            
            // ----------------------------------------------------
            // 监控 2：判断 JALR 跳过逻辑是否失败（PC 是否掉入了偏移 0xA8/0xAC 区域）
            // ----------------------------------------------------
            if (U_RISCV.U_PC.PC == (PC_BASE + 32'h000000A8) || 
                U_RISCV.U_PC.PC == (PC_BASE + 32'h000000AC)) begin
                test_failed_jalr_skip = 1;
            end
            
            // ----------------------------------------------------
            // 监控 3：到达程序的最后一条原地死循环指令 (偏移 0xB4)
            // ----------------------------------------------------
            if (U_RISCV.U_PC.PC == (PC_BASE + 32'h000000B4)) begin
                ipc_value = $itor(total_instrs) / $itor(total_cycles); 
                
                // 动态计算期望的寄存器值：PC_BASE + 0xA8 = 0x20A8
                if (U_RISCV.U_RF.register[30] == 32'h000000ab && 
                    U_RISCV.U_RF.register[8]  == (PC_BASE + 32'h000000A8) &&
                    U_RISCV.U_RF.register[9]  == (PC_BASE + 32'h000000A8) &&
                    U_RISCV.U_RF.register[10] == 32'h00000000 &&
                    test_failed_beq == 0 && test_failed_jalr_skip == 0) 
                begin
                    $display("\n=============================================");
                    $display("  [SUCCESS] All 16 Instructions Passed! ");
                    $display("  [v] x[30] == 0xAB       (Load/Store & Branch OK)");
                    $display("  [v] x[8]  == 0x%08X (JALR Link Address OK)", (PC_BASE + 32'h000000A8));
                    $display("  [v] x[9]  == 0x%08X (JALR Target Jump OK)", (PC_BASE + 32'h000000A8));
                    $display("  [v] x[10] == 0x00000000 (JALR Skip Logic OK)");
                    $display("  ---------------------------------------------");
                    $display("  Final PC           : 0x%08X", U_RISCV.U_PC.PC);
                    $display("  Total Cycles       : %0d", total_cycles);
                    $display("  Total Instructions : %0d", total_instrs);
                    $display("  Final IPC          : %0.3f", ipc_value);
                    $display("=============================================\n");
                end else begin
                    $display("\n=============================================");
                    $display("  [FAILED] Simulation Failed at the End! ");
                    
                    if (test_failed_beq) 
                        $display("  Reason: Branch 'beq' failed. PC hit offset 0x88.");
                    else if (test_failed_jalr_skip)
                        $display("  Reason: JALR jump failed. PC executed skipped instr at offset 0xA8/0xAC.");
                    else begin
                        $display("  Reason: Final Register values are wrong.");
                        $display("  Expected: x30=0x000000AB, x8=0x%08X, x9=0x%08X, x10=0x00000000", 
                                 (PC_BASE + 32'h000000A8), (PC_BASE + 32'h000000A8));
                        $display("  Actual  : x30=0x%08X, x8=0x%08X, x9=0x%08X, x10=0x%08X", 
                                 U_RISCV.U_RF.register[30], U_RISCV.U_RF.register[8], 
                                 U_RISCV.U_RF.register[9], U_RISCV.U_RF.register[10]);
                    end
                    $display("  ---------------------------------------------");
                    $display("  Final IPC          : %0.3f", ipc_value);
                    $display("=============================================\n");
                end
                
                $finish; // 结束仿真
            end
        end
    end

    // ========================================================
    // Verdi 波形导出 (FSDB)
    // ========================================================
    initial begin
        $fsdbDumpvars(0, "riscv_sim"); 
        $fsdbDumpMDA(0, "riscv_sim");  
    end

endmodule