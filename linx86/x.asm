; dunno
; @febnug

global _start
section .text

_start:

    xor     esi, esi
    lea     ebx, [esi+0x1]
    lea     edx, [esi+0x8]
    push    dword [dword 0xaaaaaaaa] ; something like "push   DWORD PTR ds:0xaaaaaaaa"
    push    dword 0xdddddddd
    mov     ecx, esp
    lea     eax, [esi+0x2]
    int     0x80
