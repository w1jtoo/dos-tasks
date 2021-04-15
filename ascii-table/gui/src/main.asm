bits    16
org     0x100

_start:
    jmp     start

%include "src/utils/std.asm"
%include "src/utils/arg_parse.asm"

start:
    IF_ARG_EQ   "LOL", .print_lol, .print_kek

.print_lol:
    PRINT_STR   "LOL"
    jmp         .exit

.print_kek:
    PRINT_STR   "KEK"
    jmp         .exit

.exit:
    mov     ah, 0x4c
    mov     al, 0x0
    int     0x21
