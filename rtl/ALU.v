`include "ctrl_signal_def.v"
`include "instruction_def.v"
module ALU(A, B, ALUOp, zero, ALU_result);
    input signed [31:0] A;
    input signed [31:0] B;
    input [3:0] ALUOp;
    output zero;
    output reg signed [31:0] ALU_result;

    // ALU 运算逻辑
    always @(*) begin
        case (ALUOp)
            `ALUOp_ADD: ALU_result = A + B;                     // add, addi, lw, sw, jalr
            `ALUOp_SUB: ALU_result = A - B;                     // sub, beq, bne
            `ALUOp_AND: ALU_result = A & B;                     // and
            `ALUOp_OR:  ALU_result = A | B;                     // or, ori
            `ALUOp_XOR: ALU_result = A ^ B;                     // xor
            `ALUOp_SRA: ALU_result = A >>> B[4:0];              // sra (算术右移)
            `ALUOp_SLL: ALU_result = A << B[4:0];               // sll (逻辑左移)
            `ALUOp_SRL: ALU_result = $unsigned(A) >> B[4:0];    // srl (逻辑右移)
            `ALUOp_BR:  ALU_result = (A == B) ? 32'h1 : 32'h0;  // beq/bne 比较
            default:    ALU_result = 32'h0;
        endcase
    end

    // zero 标志：用于分支判断
    assign zero = (ALU_result == 32'h0);

endmodule