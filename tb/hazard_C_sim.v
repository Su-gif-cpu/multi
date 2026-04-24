`timescale 1 ps / 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: hazard C - WAW + forwarding
//////////////////////////////////////////////////////////////////////////////////

module hazard_C_sim ();
    reg clk, rst;

    riscv U_RISCV(
        .clk(clk),
        .rst(rst)
    );

    initial begin
        $readmemh("../hex/hazard_C.hex", U_RISCV.U_IM.memory);
        $display("[hazard C] Instruction memory initialized");
        clk = 1;
        rst = 1;
        #20 rst = 0;
    end

    always
        #(50) clk = ~clk;

    initial begin
        repeat (40) @(posedge clk);
        $display("[hazard C] x5=%08X x6=%08X", U_RISCV.U_RF.register[5], U_RISCV.U_RF.register[6]);
        $finish;
    end

endmodule
