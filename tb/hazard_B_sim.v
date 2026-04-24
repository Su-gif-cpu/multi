`timescale 1 ps / 1 ps

module hazard_B_sim ();
    reg clk, rst;
    integer cycle_cnt;

    riscv U_RISCV(
        .clk(clk),
        .rst(rst)
    );

    // 1. 生成波形文件 - 导出所有信号以便波形查看
    initial begin
        $fsdbDumpfile("tb.fsdb");
        $fsdbDumpvars(0, hazard_B_sim);
        // $fsdbDumpMDA();  // 如需查看内存，取消注释
    end

    // 2. 复位时序 - 与 hazard_A_sim.v 保持一致
    initial begin
        $readmemh("../hex/hazard_B.hex", U_RISCV.U_IM.memory);
        $display("[hazard B] Instruction memory initialized");
        clk = 1;      
        rst = 1;
        #20 rst = 0;  
        cycle_cnt = 0;
    end

    // 时钟周期 100ps
    always #(50) clk = ~clk;

    // 3. 监测死锁：如果 PC 不变，则打印警告
    initial begin
        integer same_pc_count = 0;
        reg [31:0] last_pc = 0;
        wait(rst == 0);
        repeat(200) begin
            @(posedge clk);
            
            if (U_RISCV.PC === last_pc) begin
                same_pc_count += 1;
                if (same_pc_count == 6) begin
                    $display("[WARNING] PC stuck at %08X, possible deadlock at time %0t", 
                        U_RISCV.PC, $time);
                end
            end else begin
                same_pc_count = 0;
            end
            last_pc = U_RISCV.PC;
        end
    end

    // 4. 超时强制退出
    initial begin
        #20000;
        $display("\n[TIMEOUT] Simulation reached 20000ps timeout");
        print_final_state();
        $finish;
    end

    // 5. 每周期跟踪和最终输出
    initial begin
        wait(rst == 0);
        
        repeat (50) begin
            print_cycle_info();
            @(posedge clk);
        end
        
        print_final_state();
        $finish;
    end

    // 打印周期信息
    task print_cycle_info;
        begin
            $display("[T=%0t Cyc=%0d] PC=%08X | IR(IF)=%08X | IR(ID)=%08X | IR(EX)=%08X | x5=%08X x2=%08X",
                $time, cycle_cnt,
                U_RISCV.PC,
                U_RISCV.in_ins,
                U_RISCV.out_ins,
                U_RISCV.id_ex_instr,
                U_RISCV.U_RF.register[5],
                U_RISCV.U_RF.register[2]
            );
            
            // 打印 Load 和 Store 操作
            if (U_RISCV.ex_mem_memwrite) begin
                $display("     [MEM] SW to addr=%0d, data=%08X", 
                    U_RISCV.ex_mem_alu[11:2], U_RISCV.ex_mem_rs2);
            end
            if (U_RISCV.ex_mem_memread) begin
                $display("     [MEM] LW from addr=%0d, data_out=%08X", 
                    U_RISCV.ex_mem_alu[11:2], U_RISCV.RD);
            end
            
            cycle_cnt += 1;
        end
    endtask

    // 打印最终状态
    task print_final_state;
        begin
            $display("\n========================================");
            $display("[FINAL RESULT]");
            $display("  x1=%08X", U_RISCV.U_RF.register[1]);
            $display("  x2=%08X", U_RISCV.U_RF.register[2]);
            $display("  x5=%08X", U_RISCV.U_RF.register[5]);
            $display("  PC=%08X", U_RISCV.PC);
            $display("  DM[500]=%08X (word address from byte 2000)", U_RISCV.U_DM.memory[500]);
            $display("========================================\n");
            
            // 验证结果
            if (U_RISCV.U_RF.register[2] === 32'h63) begin
                $display("[PASS] x2 has expected value 0x63");
            end else begin
                $display("[FAIL] x2 has unexpected value 0x%X (expected 0x63)", 
                    U_RISCV.U_RF.register[2]);
            end
        end
    endtask

endmodule