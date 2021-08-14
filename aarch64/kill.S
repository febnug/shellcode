.text

.global _start
_start:

     mov x8, #0x81 // kill syscall
     mvn x0, x2 // mirip instruksi not di x86
                // jadi x2 = -1 , hasil disimpan di x0
     mov x1, #0x9
     svc #0x1337
