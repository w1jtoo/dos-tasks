bits    16
org     0x100

%include    "src/utils/std.asm"

%macro PLAY 1
    mov     ax, [ %1 ]
    call    play_freq
    call    pause
    call    stop_playing
%endmacro


start:
    call    init_int9

.loop:
    hlt

    mov     bx, [ibuff.tail]
    cmp     bx, [ibuff.head]
    jz      .update

    xor     ax, ax
    call    pop_buffer

    cmp     ax, 0x1
    je      .ret

    cmp     ax, 0x35
    je      .play_ee

    call    update_note

    jmp     .loop

.update:
    call    play_average
    jmp     .loop

.play_ee:
    PLAY    do2
    hlt
    PLAY    do2
    PLAY    sol2
    PLAY    do2
    PLAY    sol_sharp2
    PLAY    do2
    PLAY    sol2
    PLAY    do2

    PLAY    sol_sharp1
    hlt
    PLAY    sol_sharp1
    PLAY    re_sharp2
    PLAY    fa2

    PLAY    sol1
    hlt
    PLAY    sol1
    PLAY    re2
    PLAY    re_sharp2

    jmp    .loop

.ret:
    call    restore_int9
    EXIT

%include "src/keyboard_handler.asm"
%include "src/audio.asm"
