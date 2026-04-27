`timescale 1 ps / 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: hazard A - load-use stall + forwarding
//////////////////////////////////////////////////////////////////////////////////

module hazard_B_sim ();
    reg clk, rst;

    riscv U_RISCV(
        .clk(clk),
        .rst(rst)
    );

    initial begin
        $readmemh("../hex/hazard_B.hex", U_RISCV.U_IM.memory);
        $display("[hazard B] Instruction memory initialized");
        clk = 1;
        rst = 1;
        #20 rst = 0;
    end

    always
        #(50) clk = ~clk;

    initial begin
        repeat (40) @(posedge clk);
        $display("[hazard B] x5=%08X x2=%08X", U_RISCV.U_RF.register[5], U_RISCV.U_RF.register[2]);
        $finish;
    end

endmodule
