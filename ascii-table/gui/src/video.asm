wait_frame:
    push    dx
    mov     dx, 0x03DA

_wait:
    ;; wait while it renders all the pixels on the screen
    in      al, dx
    test    al, 0x08
    jnz     _wait

_end:
    in      al, dx
    test    al, 0x08
    jz      _end
    pop     dx
    ret

;; ax -- mode nubmer
init_video:
    mov     ax, 0x3
    int     0x10

    mov     ax, 0xA000
    mov     es, ax

    ret

restore_video:
    ;; back to text mode
    ;; TODO: run back to last lunched mode
    mov     ax, 0x03
    int     0x10
    ret

draw_line:
    push    ax
    push    bx
    push    es
    push    di

    call    get_line_start_address
    call    get_buffer_start_address

    xor     bh, bh
    mov     al, 'A'
    mov     word es:[di], ax

    pop     di
    pop     es
    pop     bx
    pop     ax

    ret

screen_width:   equ 0x10

get_buffer_start_address:
    push    ax

    mov     ax, 0xb800
    mov     es, ax

    pop     ax
    ret

get_line_start_address:
    push    ax
    push    bx
    push    dx
    push    es

    xor     bx, bx
    mov     bl, screen_width
;;    mul     bx
;;
;;    shl     ax, 1
;;    mov     di, ax
;;
;;    xor     bx, bx
;;    mov     es, bx
    xor     di, di
    add     di, word es:[0x44e]

    pop     es
    pop     dx
    pop     bx
    pop     ax

    ret
