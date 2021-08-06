.text
.global _start

_start:

      mov   x8, #93
      mov   x0, xzr
      svc   #0x1337
