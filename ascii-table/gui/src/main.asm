bits    16
org     0x100

_start:
    jmp     start

%include "src/utils/std.asm"
%include "src/utils/arg_parse.asm"

start:
    call    init_video
    call    init_keyboard

.loop:
    call    draw_line
    call    wait_frame

    cmp     byte [any_key_pressed], 1

    jne     .loop

;    IF_ARG_EQ   "320", .print_lol, .print_kek
;
;.print_lol:
;    PRINT_STR   "LOL"
;    jmp         .exit
;
;.print_kek:
;    PRINT_STR   "KEK"
;    jmp         .exit
;
.exit:
    call restore_video
    call restore_keyboard

    mov     ah, 0x4c
    mov     al, 0x0
    int     0x21

any_key_pressed:    db 0


%include "src/video.asm"
%include "src/keyboard.asm"
