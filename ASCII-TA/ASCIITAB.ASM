CHARS_SIZE=10h
TABLE_SIZE=16*16

model tiny
.code
    org     100h

    main:
        xor  cx, cx
        _loop:
            inc cx

            mov ax, cx
            dec ax
            mul char_size

            call fill_in_chars
            call print_chars

            cmp  cx, CHARS_SIZE
            jne  _loop
        ret

    ; fills in chars memory segment
    ; ax should contain an offset
    fill_in_chars:
        push cx
        xor  cx, cx
        mov  bx, offset chars

        inline_loop:
            inc  cx

            call to_printable
            mov  [bx], al
            inc  ax
            inc  bx

            cmp  cx, [char_size]
            jne  inline_loop

        pop  cx
        ret

    ; return char to ax
    to_printable: ; in al should be buffer index
        push cx
        push bx
        mov  bx, offset unprintable_chars
        xor  cx, cx

        _unpritable_chars_loop:
            inc cx

            cmp al, [bx]
            je _return_dot
            inc bx

            cmp cx, unprintable_len
            jne _unpritable_chars_loop
        jmp _return_ax

        _return_dot:
            mov al, 2Eh
        _return_ax:

        pop bx
        pop cx
        ret

    print_chars:
        mov  ah, 09h
        mov  dx, offset chars
        int  21h
        ret

    chars               db  CHARS_SIZE dup (0h), 0dh, 0ah, "$"
    unprintable_chars   db  0h
    unprintable_len     dw  1
    char_size           dw  CHARS_SIZE
    end main
