global _start
section .text

_start:

  mov     al, 88
  mov     ebx, 0xfee1dead
  mov     ecx, 0x28121969
  mov     edx, 0x1234567
  int     0x80
