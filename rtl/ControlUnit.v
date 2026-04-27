`include "ctrl_signal_def.v"
`include "instruction_def.v"

module ControlUnit(
    input clk, rst, zero,
    input [6:0] opcode,
    input [6:0] Funct7,
    input [2:0] Funct3,
    output reg PCWrite, InsMemRW, IRWrite, RFWrite,
    output reg [1:0] DMCtrl, ExtSel, ALUSrcA,
    output reg [1:0] ALUSrcB, RegSel, NPCOp, WDSel,
    output reg [3:0] ALUOp
);

    localparam S_FETCH = 2'd0;
    localparam S_EXEC  = 2'd1;
    localparam S_WB    = 2'd2;

    reg [1:0] state, next_state;

    always @(posedge clk or posedge rst) begin
        if (rst) state <= S_FETCH;
        else     state <= next_state;
    end

    always @(*) begin
        case(state)
            S_FETCH: next_state = S_EXEC;
            S_EXEC:  next_state = (opcode == `INSTR_LW_OP) ? S_WB : S_FETCH; // LW去WB，其余直接进入下一次取指
            S_WB:    next_state = S_FETCH;
            default: next_state = S_FETCH;
        endcase
    end

    always @(*) begin
        // 默认全关
        PCWrite = 0; InsMemRW = 0; IRWrite = 0; RFWrite = 0; DMCtrl = 2'b00;
        ExtSel = `ExtSel_SIGNED; ALUSrcA = `ALUSrcA_A; ALUSrcB = `ALUSrcB_B;
        RegSel = `RegSel_rd; NPCOp = `NPC_PC; WDSel = `WDSel_FromALU; ALUOp = `ALUOp_ADD;

        case(state)
            S_FETCH: begin
                InsMemRW = 1; 
            end
            S_EXEC: begin
                InsMemRW = 1; // 保持指令有效
                case(opcode)
                    `INSTR_RTYPE_OP: begin
                        ALUSrcA = `ALUSrcA_A; ALUSrcB = `ALUSrcB_B;
                        case({Funct7, Funct3})
                            `INSTR_ADD_FUNCT: ALUOp = `ALUOp_ADD;
                            `INSTR_SUB_FUNCT: ALUOp = `ALUOp_SUB;
                            `INSTR_AND_FUNCT: ALUOp = `ALUOp_AND;
                            `INSTR_OR_FUNCT:  ALUOp = `ALUOp_OR;
                            `INSTR_XOR_FUNCT: ALUOp = `ALUOp_XOR;
                            `INSTR_SLL_FUNCT: ALUOp = `ALUOp_SLL;
                            `INSTR_SRL_FUNCT: ALUOp = `ALUOp_SRL;
                            `INSTR_SRA_FUNCT: ALUOp = `ALUOp_SRA;
                        endcase
                        RFWrite = 1; PCWrite = 1; // 算完立刻写RF和PC
                    end
                    `INSTR_ITYPE_OP: begin
                        ALUSrcA = `ALUSrcA_A; ALUSrcB = `ALUSrcB_Imm;
                        if (Funct3 == `INSTR_ORI_FUNCT) begin ExtSel = `ExtSel_ZERO; ALUOp = `ALUOp_OR; end 
                        else begin ExtSel = `ExtSel_SIGNED; ALUOp = `ALUOp_ADD; end
                        RFWrite = 1; PCWrite = 1;
                    end
                    `INSTR_SW_OP: begin
                        ALUSrcA = `ALUSrcA_A; ALUSrcB = `ALUSrcB_Offset; ALUOp = `ALUOp_ADD;
                        DMCtrl = 2'b10; PCWrite = 1;
                    end
                    `INSTR_LW_OP: begin
                        ALUSrcA = `ALUSrcA_A; ALUSrcB = `ALUSrcB_Imm; ALUOp = `ALUOp_ADD;
                        DMCtrl = 2'b01; // 仅发起读存，PC留到WB再更新
                    end
                    `INSTR_BTYPE_OP: begin
                        ALUSrcA = `ALUSrcA_A; ALUSrcB = `ALUSrcB_B; ALUOp = `ALUOp_SUB; PCWrite = 1;
                        if ((Funct3 == `INSTR_BEQ_FUNCT && zero) || (Funct3 == `INSTR_BNE_FUNCT && !zero)) NPCOp = `NPC_Offset12; 
                        else NPCOp = `NPC_PC;
                    end
                    `INSTR_JAL_OP: begin
                        PCWrite = 1; NPCOp = `NPC_Offset20;
                        RFWrite = 1; WDSel = `WDSel_FromPC;
                    end
                    `INSTR_JALR_OP: begin
                        ALUSrcA = `ALUSrcA_A; ALUSrcB = `ALUSrcB_Imm; ALUOp = `ALUOp_ADD;
                        PCWrite = 1; NPCOp = `NPC_rs;
                        RFWrite = 1; WDSel = `WDSel_FromPC;
                    end
                endcase
            end
            S_WB: begin // 仅LW进入此状态
                PCWrite = 1;
                RFWrite = 1; WDSel = `WDSel_FromMEM;
            end
        endcase
    end
endmodule