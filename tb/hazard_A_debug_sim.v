`timescale 1 ps / 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Debug testbench for hazard A - with detailed signal logging
//////////////////////////////////////////////////////////////////////////////////

module hazard_A_debug_sim ();
    reg clk, rst;

    riscv U_RISCV(
        .clk(clk),
        .rst(rst)
    );

    initial begin
        $readmemh("../hex/hazard_A.hex", U_RISCV.U_IM.memory);
        $display("[hazard A debug] Instruction memory initialized");
        clk = 1;
        rst = 1;
        #20 rst = 0;
    end

    always
        #(50) clk = ~clk;

    // Detailed trace: focus on the critical window
    always @(posedge clk) begin
        if (!rst) begin
            $display("[t=%0t] PC=%08X IR=%08X", $time, U_RISCV.PC, U_RISCV.out_ins);
            $display("  | IF/ID: if_id_rs1=%d if_id_rs2=%d if_id_opcode=%x",
                U_RISCV.if_id_rs1, U_RISCV.if_id_rs2, U_RISCV.if_id_opcode);
            $display("  | EX: id_ex_opcode=%x id_ex_rd=%d id_ex_regwrite=%b id_ex_memread=%b",
                U_RISCV.id_ex_opcode, U_RISCV.id_ex_instr[11:7], U_RISCV.id_ex_regwrite, U_RISCV.id_ex_memread);
            $display("  | Fwd: rs1_fwd=%08X rs2_fwd=%08X", U_RISCV.rs1_fwd, U_RISCV.rs2_fwd);
            $display("  | Hzd: stall_ld=%b stall_ex=%b stall_mem=%b",
                U_RISCV.stall_ld, U_RISCV.stall_ex_hzd, U_RISCV.stall_mem_hzd);
            $display("  | Regs: x1=%08X x5=%08X x6=%08X", 
                U_RISCV.U_RF.register[1], U_RISCV.U_RF.register[5], U_RISCV.U_RF.register[6]);
        end
    end

    initial begin
        repeat (50) @(posedge clk);
        $display("\n[Final] x1=%08X x5=%08X x6=%08X x7=%08X", 
            U_RISCV.U_RF.register[1], U_RISCV.U_RF.register[5], 
            U_RISCV.U_RF.register[6], U_RISCV.U_RF.register[7]);
        $finish;
    end

endmodule
