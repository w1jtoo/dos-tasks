bits    16
org     0x100

_start:
    jmp     start

%include    "src/utils/std.asm"
%include    "src/utils/str.asm"
%include    "src/keyboard_handler.asm"

%define     NEW_LINE    0xa, 0xd

promt:  db  "     This program shows state of keyboard", NEW_LINE
        db  " buffer. This buffer uses self written 9th", NEW_LINE
        db  " interruption  emulation.", NEW_LINE, NEW_LINE
        db  "    enter   - push the print of buffer state", NEW_LINE
        db  "    escape  - exit the program", NEW_LINE, '$'

start:
    call    init_int9

    call    print_line
    PRINT_PTR     promt
    call    print_line
.loop:
    hlt

    mov     bx, [ibuff.tail]
    cmp     bx, [ibuff.head]
    jz      .loop

    mov     bl, byte [ibuff.flags]
    cmp     bl, OVERFLOW_FLAG       ;; todo fix flag size byte -> bit
    jz     .overflow

    push    bx
    push    ax

    mov     bx, word [ibuff.head]
.contains_loop:
    xor     ax, ax
    mov     ah, byte [bx]

    cmp     ah, 0x1
    je      .exit

    cmp     ah, 0x1c
    je      .print_buffer

    cmp     bx, [ibuff.tail]
    je      .ret

    inc     bx
    cmp     bx, ibuff.end
    jnz     .to_end

    mov     bx, ibuff.buffer
.to_end:
    jmp     .contains_loop

.ret:
    pop     ax
    pop     bx

    jmp     .loop

.overflow:
    call    print_line
    PRINT_PTR       overflow
    call    print_kb_struct
    call    pop_all_buffer
    call    print_line

    jmp     .loop
.print_buffer:
    call    print_line
    call    print_kb_struct
    call    pop_all_buffer
    call    print_line

    jmp     .loop

.exit:
    call    restore_int9
    EXIT

print_line:
    PRINTLN_STR       "============================================"
    ret

description:
            db NEW_LINE
.l1:        db "Head index: 0x"
.head:      dw  0x0
            db NEW_LINE
.l2:        db "Tail index: 0x"
.tail:      dw 0x0
            db NEW_LINE
.l3:        db "Overflow flag:"
.overflow:  dw 0x0
            db NEW_LINE, '$'

overflow:
    db "Buffer overflow. Print buffer state and", NEW_LINE
    db "clean the buffer.", NEW_LINE, NEW_LINE, '$'

print_kb_struct:
    push    ax

    PRINT_STR       "Buffer state: "
    call            print_buffer

    mov     ax, word [ibuff.head]
    sub     ax, ibuff.buffer
    TO_HEX  al
    mov     [description.head], ax

    mov     ax, word [ibuff.tail]
    sub     ax, ibuff.buffer
    TO_HEX  al
    mov     [description.tail], ax

    xor     bx, bx
    mov     al, byte [ibuff.flags]
    cmp     al, OVERFLOW_FLAG
    jne     .ret

    inc     bx
.ret:
    add     bx, '0'
    mov     [description.overflow], bx

    PRINT_PTR       description
    pop     ax
    ret


tmp:    dw 0x0, '$'
print_buffer:
    push    bx
    push    ax

    mov     bx, word [ibuff.head]
.loop:
    xor     ax, ax
    mov     ah, byte [bx]

    call    to_scan_code
    mov     [tmp], ax
    PRINT_PTR   tmp

    mov     al,     ' '
    call    print_al

    cmp     bx, [ibuff.tail]
    je      .ret

    inc     bx
    cmp     bx, ibuff.end
    jnz     .to_end

    mov     bx, ibuff.buffer
.to_end:
    jmp     .loop

.ret:
    pop     ax
    pop     bx
    ret

print_al:
    PRINT_CHAR  al
    ret


to_scan_code:
    push    bx

    mov     bx, ax

    and     ax, 0xf000
    shr     ax, 0xc
    TO_HEX  al

    and     bx, 0xf00
    shr     bx, 0x8
    TO_HEX  bl
    shl     bx, 0x8

    add     ax, bx

    pop     bx
    ret

pop_all_buffer:
    push    ax
    push    dx
.loop:
    mov     bx, [ibuff.head]
    cmp     bx, [ibuff.tail]
    je     .ret

    call    pop_and_clean_buffer

    jmp     .loop

.ret:
    pop     dx
    pop     ax

    ret