.text
.global _start

_start:

      mov   x8, #93 // exit syscall
      mov   x0, xzr
      svc   #0x1337
