%define     OFFSET_TO_HANDLER   0x24
%define     BUFFER_SIZE         0x10
%define     OVERFLOW_FLAG       10000000b
old_handler:
    .segment:   dw  0
    .addres:    dw  0

ibuff: 
    .buffer:    times BUFFER_SIZE db 0
    .end:
    .head:      dw ibuff.buffer
    .tail:      dw ibuff.buffer
    .flags:     db 0

_push_to_buffer:
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
    mov     ax, _int9
    mov     [OFFSET_TO_HANDLER], ax

    mov     ax, cs
    mov     [OFFSET_TO_HANDLER + 2], ax
    sti

    pop     di
    pop     si
    pop     ds
    pop     ax

    ret

_int9:
    push    ax

    in      al, 0x60
    call    _push_to_buffer

    mov     al, 0x20
    out     0x20, al

    pop     ax
    iret


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