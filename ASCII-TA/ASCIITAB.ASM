CHARS_SIZE=10h
TABLE_SIZE=16*16

model tiny
.code
    org     100h


    main:
        xor  cx, cx

        _loop:
            cmp  cx, TABLE_SIZE - 1
            je   _return

            mov  dx, cx
            cmp  dx, 0          ;; dx == 0
            je   _continue

            and  dx, 0fh
            cmp  dx, 0          ;; dx % 16 == 0
            je   _print_endl
        _continue:
            mov  ax, dx
            call to_printable   ;; filtred cx to dx
            call print_char     ;; dx to stdout

            inc  cx
            jmp  _loop

        _print_endl:            ;; prints new line symblos
            mov ah, 09h
            mov dx, offset endl
            int 21h
            jmp _continue

        _return:
            ret

    ;; takes char from dx and print it
    print_char:
        mov ah, 02h
        int 21h
        ret

    ;; takes char from cx and changes value to dot if char is in char array
    ;; returns char to dx
    to_printable:
        mov  bx, offset unprintable_chars
        mov  dx, cx

        _unpritable_chars_loop:
            cmp bx, offset unprintable_end
            je _return_ax

            cmp dl, [bx]
            je _return_dot

            inc bx
            jmp _unpritable_chars_loop

        _return_dot:
            mov dl, 2Eh
        _return_ax:

        ret

    endl                db  0dh, 0ah, "$"
    unprintable_chars   db  0ah, 0dh
    unprintable_end     dw  $
    end main
