%macro EXIT 0
    mov     ax, 0x0
    int     0x21
%endmacro
