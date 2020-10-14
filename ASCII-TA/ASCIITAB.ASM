CHARS_SIZE=16
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

        inline_loop:
            inc  cx

            mov  bx,  offset chars
            add  ax,  cx
            add  bx,  cx

            ; call to_printable
            mov  [bx], ax

            cmp  cx, TABLE_SIZE
            jne  inline_loop

        pop  cx
        ret

    ; return char to ax
    to_printable: ; in cx should be buffer index
        push ax
        push bx
        xor  ax, ax
        _unpritable_chars_loop:
            inc ax

            mov bx, offset unprintable_chars
            add bx, ax

            cmp cx, [bx]
            je _return_dot

            cmp ax, unprintable_len
            jne _unpritable_chars_loop
        jmp _return_ax

        _return_dot:
            mov ax, 2Eh
        _return_ax:

        pop bx
        pop ax
        ret

    print_chars:
        mov  ah, 09h
        mov  dx, offset chars
        int  21h
        ret

    chars               db  CHARS_SIZE dup (0h), 0dh, 0ah, "$"
    unprintable_chars   db  20h
    unprintable_len     dw  1
    char_size           dw  CHARS_SIZE
    end main
