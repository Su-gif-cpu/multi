`include "ctrl_signal_def.v"
`include "instruction_def.v"
module NPC(NPCOp, Offset12, Offset20, PC, rs, PCA4, NPC);
    input [1:0] NPCOp;      //控制信号
    input [12:1] Offset12;  //比较指令的跳转偏移量
    input [20:1] Offset20;  //跳转指令的跳转偏移量
    input [31:0] PC;        //多周期核中在 IF2 之后为「当前 IR 指令地址 + 4」（顺序下一条）
    input [31:0] rs;        //跳转到子程序的地址
    output reg [31:0] PCA4; //PC+4
    output reg [31:0] NPC;  //下一条指令的地址

    wire signed [31:0] Offset13;
    wire signed [31:0] Offset21;

    // Bug N2 修复：正确的符号扩展到32位
    assign Offset13 = {{19{Offset12[12]}}, Offset12[12:1], 1'b0};
    assign Offset21 = {{11{Offset20[20]}}, Offset20[20:1], 1'b0};

    // 注：多周期取指在 IF2 已将 PC 更新为「本条指令地址 + 4」，故相对跳转目标需用 PC + imm - 4
    always @(*) begin
        case (NPCOp)
            `NPC_PC         : NPC = PC + 32'd4;
            `NPC_Offset12   : NPC = PC + Offset13 - 32'd4;      // B-type：PC 已为 seq_pc，补回 -4
            `NPC_rs         : NPC = {rs[31:1], 1'b0};           // JALR：(rs1+imm) 最低位清 0，rs 接 ALU 结果
            `NPC_Offset20   : NPC = PC + Offset21 - 32'd4;      // JAL：同上
            default:         NPC = PC + 32'd4;
        endcase
        PCA4 = PC + 32'd4;
    end
endmodule