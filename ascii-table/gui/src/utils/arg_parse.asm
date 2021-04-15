%define END_STR     '$'
%define ARGS_START  0x82

; arg1: str equal one
; arg2: pointer to go to if equal
; arg3: pointer to go to otherwise

%macro IF_ARG_EQ 3
    push    si
    push    di
    push    ds
    push    es
    push    ax

    cld
    mov     cx, %%len
    lea     si, %%eq
    lea     di, ARGS_START

    repe    cmpsb
    jne     %%else

    _POP_ALL
    jmp     %2

%%else:
    _POP_ALL
    jmp     %3

%%eq:       db  "LOL"
%%len:      equ $-%%eq
%endmacro

%macro _POP_ALL 0
    pop ax
    pop es
    pop ds
    pop di
    pop si
%endmacro
