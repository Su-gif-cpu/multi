`timescale 1 ps / 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: lw-use hazard test
//////////////////////////////////////////////////////////////////////////////////

module lw_use_sim ();
    reg clk, rst;

    riscv U_RISCV(
        .clk(clk),
        .rst(rst)
    );

    initial begin
        $readmemh("../hex/lw_use_test.hex", U_RISCV.U_IM.memory);
        $display("[lw_use_test] Instruction memory initialized");
        clk = 1;
        rst = 1;
        #20 rst = 0;
    end

    always
        #(50) clk = ~clk;

    initial begin
        $fsdbDumpvars(0, "lw_use_sim");
        $fsdbDumpMDA(0, "lw_use_sim");
    end

    initial begin
        repeat (30) @(posedge clk);
        $display("[lw_use_test] x3 = 0x%08X", U_RISCV.U_RF.register[3]);
        if (U_RISCV.U_RF.register[3] !== 32'd21) begin
            $display("[lw_use_test] FAILED: expected x3 == 21, got %0d", U_RISCV.U_RF.register[3]);
        end else begin
            $display("[lw_use_test] PASSED");
        end
        $finish;
    end

endmodule
