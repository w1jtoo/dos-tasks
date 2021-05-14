%define     MAX_HZ                          0x12

%define     CONTROL_WORD_REGISTER           0x43
%define     TIMER_COUNTER_REGISTER0         0x40
%define     TIMER_COUNTER_REGISTER1         0x41
%define     TIMER_COUNTER_REGISTER2         0x42

%define     SPEAKER_PORT                    0x61
pause:
    push    ax
    push    dx
    push    cx

    mov     cx, 6
    xor     dx, dx
    mov     ah, 86h
    int     15h

    pop     cx
    pop     dx
    pop     ax
    ret

play_freq:
    push    ax
    push    cx
    push    dx

    mov     dx, MAX_HZ
    cmp     ax, dx
    jbe     .ret

    mov     cx, ax
    in      al, SPEAKER_PORT
    or      al, 0x3
    out     SPEAKER_PORT, al

    mov     al, 10110110b
    out     CONTROL_WORD_REGISTER, al

    mov     ax, 0x34dd
    div     cx
    out     TIMER_COUNTER_REGISTER2, al

    mov     al, ah
    out     TIMER_COUNTER_REGISTER2, al

    .ret:
    pop     dx
    pop     cx
    pop     ax

    ret

stop_playing:
    push    ax

    in      al, SPEAKER_PORT
    and     al, !3
    out     SPEAKER_PORT, al

    pop     ax

    ret

update_note:
    push    ax
    push    bx

    mov     ah, al
    and     ah, 0x7f

    cmp     ah, keys_end_scancode
    jg      .ret

    lea     bx, press_keymap

    test    al, 0x80
    jnz     .released

    and     ax, 0x07f
    add     bx, ax
    mov     byte [bx], 1

    jmp     .ret

.released:
    and     ax, 0x7f
    add     bx, ax
    mov     byte [bx], 0

.ret:
    pop     bx
    pop     ax
    ret

play_average:
    push    ax

    call    get_average
    test    ax, ax
    jz      .stop

    call    play_freq

    jmp     .ret

.stop:
    call    stop_playing

.ret:
    pop     ax
    ret


get_average:
    push    bp
    push    cx
    push    dx
    push    bx
    push    di
    push    si

    lea     di, press_keymap
    lea     si, notes

    xor     cx, cx
    xor     bp, bp
    xor     ax, ax

.loop:
    mov     dl, byte [di]
    mov     bx, word [si]

    test    dl, dl
    jz      .continue

    test    bx, bx
    jz      .continue

    add     ax, bx
    inc     bp

.continue:
    add     si, 2
    inc     di
    inc     cx
    cmp     cx, press_keymap_len
    jb      .loop

    test    ax, ax
    jz      .ret

    mov     bx, bp
    test    bx, bx
    jz      .ret
    xor     dx, dx
    div     bx

.ret:
    pop     si
    pop     di
    pop     bx
    pop     dx
    pop     cx
    pop     bp

    ret


notes:
    dw 0, 0

    do1:            dw 261
    do_sharp1:      dw 277
    re1:            dw 293
    re_sharp1:      dw 311
    mi1:            dw 329
    fa1:            dw 349
    fa_sharp1:      dw 369
    sol1:           dw 392
    sol_sharp1:     dw 415
    la1:            dw 440
    la_sharp1:      dw 466
    si1:            dw 493


    dw 0, 0

    do2:            dw 523
    do_sharp2:      dw 554
    re2:            dw 587
    re_sharp2:      dw 622
    mi2:            dw 659
    fa2:            dw 698
    fa_sharp2:      dw 740
    sol2:           dw 784
    sol_sharp2:     dw 831
    la2:            dw 880
    la_sharp2:      dw 932
    si2:            dw 988

    keys_end_scancode:      equ 1Bh
    press_keymap_len:       equ (keys_end_scancode + 1)
    press_keymap:           db press_keymap_len dup (0)

    do3 equ 1046
    re3 equ 1174