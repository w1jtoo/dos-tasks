%macro PRINT_STR 1
    push    ax
    push    dx

    mov     ah, 0x9
    mov     dx, %%str
    int     0x21

    pop     dx
    pop     ax

    jmp     %%end+1
%%str:  db  %1, '$'
%%end:
%endmacro

%macro PRINT_PTR 1
    push    ax
    push    dx

    mov     ah, 0x9
    mov     dx, %1
    int     0x21

    pop     dx
    pop     ax
%endmacro

%macro PRINT_CHAR 1
    mov     dl, byte %1
    mov     ah, 0x2
    int     0x21
%endmacro
