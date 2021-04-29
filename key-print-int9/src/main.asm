bits    16
org     0x100

%include    "src/utils/std.asm"
%include    "src/utils/macro.asm"

%define     OVERFLOW_FLAG 0xff

start:
    call    init_int9

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
.loop1:
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
    jmp     .loop1

.ret:
    pop     ax
    pop     bx

    jmp     .loop

.overflow:
    PRINT_PTR       overflow
    call    print_kb_struct
    call    pop_all_buffer

    jmp     .loop
.print_buffer:
    call    print_kb_struct
    call    pop_all_buffer

    jmp     .loop

.exit:
    call    restore_int9
    EXIT

%macro TO_HEX 1
    add     byte %1, '0'
    cmp     byte %1, '9'
    jna     %%ret

    add    %1, 'A'- '9' + 1
%%ret:
%endmacro

%define     NEW_LINE    0xa, 0xd
description:
            dw NEW_LINE
.l1:        dw "Head index: 0x"
.head:      dw  0x0, NEW_LINE
.l2:        dw "Tail index: 0x"
.tail:      dw 0x0, NEW_LINE
.l3:        dw "Overflow flag: "
.overflow:  dw 0x0, NEW_LINE, '$'

overflow:
    dw "Buffer overflow.", NEW_LINE, '$'

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

    call    pop_buffer

    jmp     .loop

.ret:
    pop     dx
    pop     ax

    ret

pop_buffer:
    push    bx

    mov     bx, [ibuff.head]
    mov     al, ds:[bx]
    inc     bx

    cmp     bx, ibuff.end
    jnz     .ret

    mov     bx, ibuff.buffer
.ret:
    mov     [ibuff.head], bx

    mov     bx, [ibuff.flags]
    mov     bx, 0x0
    mov     [ibuff.flags], bx

    pop     bx
    ret


push_to_buffer:
    push    di
    push    bx
    push    bp

    mov     di, cs:[ibuff.tail]
    mov     bx, di
    inc     di

    cmp     di, ibuff.end
    jnz     .to_tail

    mov     di, ibuff.buffer

.to_tail:
    mov     bp, di
    cmp     di, cs:[ibuff.head]
    jz      .overflow

    mov     di, bx
    mov     byte cs:[di], al
    mov     cs:[ibuff.tail], bp

    jmp     .ret

.overflow:
    mov     bp, cs:[ibuff.flags]
    or      bp, OVERFLOW_FLAG
    mov     cs:[ibuff.flags], bp

.ret:
    pop     bp
    pop     bx
    pop     di

    ret

%define     OFFSET_TO_HANDLER   0x24
init_int9:
    push    ax
    push    ds
    push    si
    push    di

    xor     ax, ax
    mov     ds, ax
    mov     si, OFFSET_TO_HANDLER
    mov     di, old_handler

    movsw
    movsw

    cli
    mov     ax, int9
    mov     [OFFSET_TO_HANDLER], ax

    mov     ax, cs
    mov     [OFFSET_TO_HANDLER + 2], ax
    sti

    pop     di
    pop     si
    pop     ds
    pop     ax

    ret

restore_int9:
    push    ax
    push    ds
    push    si
    push    di
    push    es

    xor     ax, ax
    mov     es, ax

    push    cs
    pop     ds

    mov     si, old_handler
    mov     di, OFFSET_TO_HANDLER

    cli
    movsw
    movsw
    sti

    pop     es
    pop     di
    pop     si
    pop     ds
    pop     ax
    ret

int9:
    push    ax

    in      al, 0x60
    call    push_to_buffer

    mov     al, 0x20
    out     0x20, al

    pop     ax
    iret

%define             buff_size 16
;;struc kb_buff
;;    .buffer         resb    buff_size
;;    .head           resw  .buffer
;;    .tail           resw  .buffer
;;endstruc


ibuff: 
    .buffer:    times buff_size db 0
    .end:
    .head:      dw ibuff.buffer
    .tail:      dw ibuff.buffer
    .flags:     db 0

old_handler:
    .segment:   dw  0
    .addres:    dw  0
