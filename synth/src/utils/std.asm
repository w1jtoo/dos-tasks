%macro PRINT_STR 1
    push    ax
    push    dx

    mov     ah, 0x9
    mov     dx, %%str
    int     0x21

    pop     dx
    pop     ax

    jmp     %%end
%%str:  db  %1, '$'
%%end:
%endmacro

%macro PRINTLN_STR 1
    push    ax
    push    dx

    mov     ah, 0x9
    mov     dx, %%str
    int     0x21

    pop     dx
    pop     ax

    jmp     %%end
%%str:  db  %1, 0xa, 0xd, '$'
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
    push    dx
    push    ax

    mov     dl, byte %1
    mov     ah, 0x2
    int     0x21

    pop     ax
    pop     dx
%endmacro

%macro EXIT 0
    mov     ax, 0x0
    int     0x21
%endmacro
