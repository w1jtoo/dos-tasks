BUFFER_LENGTH = 128

model tiny
.code
    org 100h
    start:

        ; Write message
        mov     bx, offset numbers
        call    parse_dec

        call    print_dec

        ; mov     ah, 09h
        ; mov     dx, offset message
        ; int     21h

        ret

    buffer  db BUFFER_LENGTH dup (24h)
    message db "Hello DOS $"
    numbers db "123$"
    include STRUTIL.ASM

    end start