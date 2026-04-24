`timescale 1 ps / 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: hazard A - load-use stall + forwarding
//////////////////////////////////////////////////////////////////////////////////

module hazard_A_sim ();
    reg clk, rst;

    riscv U_RISCV(
        .clk(clk),
        .rst(rst)
    );

    initial begin
        $readmemh("../hex/hazard_A.hex", U_RISCV.U_IM.memory);
        $display("[hazard A] Instruction memory initialized");
        clk = 1;
        rst = 1;
        #20 rst = 0;
    end

    always
        #(50) clk = ~clk;

    initial begin
        repeat (40) @(posedge clk);
        $display("[hazard A] x5=%08X x6=%08X x7=%08X", U_RISCV.U_RF.register[5], U_RISCV.U_RF.register[6], U_RISCV.U_RF.register[7]);
        $finish;
    end

endmodule
