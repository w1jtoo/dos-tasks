CHARS_SIZE=16
TABLE_SIZE=16

model tiny
.code
    org     100h

    main:
        xor  cx, cx
        
        .loop:
            mov  bx,   offset chars
            add  bx,   cx
            mov  byte ptr bx, cx
            call to_printable

            cmp  cx, TABLE_SIZE
            inc  cx
            jne  .loop

        call print_chars
        ret

    to_printable: ; in ax should be buffer index
        ret

    print_chars:
        mov  ah, 09h 
        mov  dx, offset chars
        int  21h
        ret

    chars   db   CHARS_SIZE+1 dup(24h)
    end main
