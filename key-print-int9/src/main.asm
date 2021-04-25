bits    16
org     0x100

%include    "src/utils/std.asm"
%include    "src/utils/macro.asm"

start:
    mov     ax, ibuff + kb_buff.buffer
    mov     ax, [ibuff + kb_buff.tail]
    mov     ax, [ibuff + kb_buff.head]
    mov     ax, ibuff + kb_buff.end

    PRINT_STR "Hello, NASM and DOS!"
    EXIT


push_to_buffer:
    push    di
    push    bx
    push    bp

    pop     bp
    pop     bx
    pop     di
    ret

int9:
    push    ax

    in      al, 0x60
    call    push_to_buffer

    mov     al, 0x20
    out     0x20, al

    pop     ax
    iret

%define             buff_size 5
struc kb_buff
    .buffer         resw    buff_size
    .end:
    .head           resw  .buffer
    .tail           resw  .buffer
endstruc

ibuff: times buff_size dw 0
        dw ibuff, ibuff

old_handler:    dw 0, 0
