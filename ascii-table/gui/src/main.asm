bits    16
org     0x100

%include "src/utils/std.asm"

start:
    PRINT_STR   "Hello world!"
    jmp         .exit

.exit:
    mov     ah, 0x4c
    mov     al, 0x0
    int     0x21
