// R-type instructions test for RISC-V CPU
#include <stdio.h>
int main()
{
    // Initialize registers with test values
    asm volatile ("ori x1, x0, 10");   // x1 = 10
    asm volatile ("ori x2, x0, 5");    // x2 = 5
    asm volatile ("ori x3, x0, 15");   // x3 = 15
    asm volatile ("ori x4, x0, 2");    // x4 = 2

    // R-type instructions
    asm volatile ("add x5, x1, x2");   // x5 = x1 + x2 = 15
    asm volatile ("sub x6, x1, x2");   // x6 = x1 - x2 = 5
    asm volatile ("and x7, x1, x3");   // x7 = x1 & x3 = 10 & 15 = 10
    asm volatile ("or x8, x1, x3");    // x8 = x1 | x3 = 10 | 15 = 15
    asm volatile ("xor x9, x1, x3");   // x9 = x1 ^ x3 = 10 ^ 15 = 5
    asm volatile ("sll x10, x1, x4");  // x10 = x1 << x4 = 10 << 2 = 40
    asm volatile ("srl x11, x3, x4");  // x11 = x3 >> x4 = 15 >> 2 = 3
    asm volatile ("sra x12, x3, x4");  // x12 = x3 >>> x4 = 15 >>> 2 = 3 (since positive)

    // Additional tests
    asm volatile ("addi x15, x0, -8");  // x15 = -8
    asm volatile ("sra x16, x15, x4"); // x16 = x15 >>> x4 = -8 >>> 2 = -2

    // Loop to halt (infinite loop)
    asm volatile ("_halt:");
    asm volatile ("jal x0, _halt");

    return 0;
}