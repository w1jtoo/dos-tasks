%macro PRINT_STR 1
%%str:  db  %1, '$'

    push    ax
    push    dx

    mov     ah, 0x9
    mov     dx, %%str
    int     0x21

    pop     ax
    pop     dx
%endmacro
