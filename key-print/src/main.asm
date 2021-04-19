bits    16
org     0x100

%include    "src/utils/std.asm"
%include    "src/utils/str.asm"
%include    "src/utils/macro.asm"
%define     ESC     0x11b

fake_start:
    jmp     start

info_start:     db "ASCII: '"
ascii:          db 0x0, 0x0
info1:          db "'; SYMBOL '", '$'
symbol:         db 0x0
info2:          db "'; SCAN '"
scan:           db 0x0, 0x0
info_end:       db "'; ESC to exit.", 0xa, 0xd,'$'

read_key:
    xor     ax, ax
    int     0x16
    ret

to_ascii_info:
    push    bx
    mov     bx, ax

    and     ax, 0x00f0
    shr     al, 0x4
    TO_HEX  al

    and     bl, 0xf
    TO_HEX  bl
    shl     bx, 0x8

    add     ax, bx
    pop     bx
    ret

to_scan_info:
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


update_info:
    push    ax
    call    to_ascii_info
    mov     word [ascii], ax
    pop     ax

    push    ax
    call    to_scan_info
    mov     word [scan], ax
    pop     ax

    ret

to_printable:
    push    bx
    mov     bx, unprintable_chars

.loop:
    cmp     bx, unprintable_chars_end
    je      .ret_ax

    cmp     al, [bx]
    je      .ret_xx

    inc     bx
    jmp     .loop

.ret_xx:
    mov     ax, 0xed
.ret_ax:
.ret:
    pop     bx
    ret 

start:
    call        read_key        ;; pressed key -> ax

    cmp         ax, ESC         ;; if pressed key is ECS
    je          .exit

    call        update_info     ;; update promt buffer
    PRINT_PTR   info_start

    call        to_printable
    PRINT_CHAR  al

    PRINT_PTR   info2

    jmp         start

.exit:
    EXIT

unprintable_chars:      db 0x0d, 0x1b, 0x08, 0x09, 0x20, 0x0, 0x34, 0x0a, 0x07
unprintable_chars_end:  dw 0x0
