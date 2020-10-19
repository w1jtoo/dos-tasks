CHARS_SIZE=10h
TABLE_SIZE=16*16

model tiny
.code
    org     100h

    main:
        xor  cx, cx
        xor  dx, dx
        _loop:
            cmp  dx, TABLE_SIZE - 1
            je  _return

            push dx
            
            cmp dx, 0
            je _continue

            and dx, 0fh
            cmp dx, 0
            je _print_endl
        _continue:
            pop dx

            mov ax, dx
            call to_printable
            call print_char

            inc  dx
            jmp  _loop
        
        _print_endl:
            mov ah, 09h
            mov dx, offset endl
            int 21h
            jmp _continue

        _return:
            ret


    print_char:
        push dx
        mov dx, ax
        mov ah, 02h
        int 21h
        pop dx
        ret


    to_printable: ; in al should be buffer index
        push bx
        mov  bx, offset unprintable_chars

        _unpritable_chars_loop:
            cmp bx, offset unprintable_end
            je _return_ax

            cmp al, [bx]
            je _return_dot

            inc bx
            jmp _unpritable_chars_loop

        _return_dot:
            mov al, 2Eh
        _return_ax:

        pop bx

        ret

    endl                db  0dh, 0ah, "$"
    unprintable_chars   db  0ah, 0dh, 24h ; 24h - brakes print :-(
    unprintable_end     dw  $
    end main
