.option rvc
.global _start
.section .text

_start:
.Lmsg:
    auipc a1, %pcrel_hi(msg)
    addi  a1, a1, %pcrel_lo(.Lmsg)

    c.li a0, 1
    c.li a2, 3

    li a7, 64
    ecall

    c.li a0, 0
    li a7, 93
    ecall

msg:
    .byte 0x46, 0x4e, 0x0a
# Build:
# riscv64-linux-gnu-as -march=rv64gc sc.S -o sc.o
# riscv64-linux-gnu-ld sc.o -o sc
# qemu-riscv64 ./sc
