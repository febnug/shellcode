global _start
section .text

_start:

mov     al, 74
push    dword 0x75736972
mov     ecx, 6
int     0x80

mov     al, 1
xor     ebx, ebx
int     0x80
