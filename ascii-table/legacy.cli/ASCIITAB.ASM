CHARS_SIZE=10h
TABLE_SIZE=16*16

model tiny
.code
    org     100h

    main:
        xor  cx, cx
        xor  ax, ax
        _loop:
            cmp  cx, CHARS_SIZE
            je  _return

            mov  ax, cx
            mov dx, CHARS_SIZE
            mul dx

            call fill_in_chars
            call print_chars

            inc  cx
            jmp  _loop

        _return:
            ret

    ; fills in chars memory segment
    ; ax should contain an offset
    fill_in_chars:
        push cx
        xor  cx, cx
        mov  bx, offset chars

        inline_loop:
            inc  cx

            mov dx, ax
            call to_printable
            mov [bx], al
            mov ax, dx

            inc  ax
            inc  bx

            cmp  cx, CHARS_SIZE
            jne  inline_loop

        pop  cx
        ret

    ; return char to ax
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

    print_chars:
        mov  ah, 09h
        mov  dx, offset chars
        int  21h
        ret

    chars               db  CHARS_SIZE dup (0h), 0dh, 0ah, "$"
    unprintable_chars   db  0ah, 0dh, 24h ; 24h - brakes print :-(
    unprintable_end     dw  $
    end main
