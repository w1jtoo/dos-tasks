BUFFER_LENGTH = 255

model tiny
.code
    include STDOU.ASM       ; include stdout macros

    org 100h
    start:

        ; Write message
        call    _read_line
        ; mov     bx, offset numbers
        ; call    parse_dec

        ; call    print_dec
        mov     cx, 3
        call    _error_print

        ; mov     ah, 09h
        ; mov     dx, offset message
        ; int     21h

        ret

    _read_line:
        mov     ah, 0Ah
        mov     dx, offset buffer
        int     21h
        ret

;; ====================== PRINT ERROR MSG ============================
;; cx - index with error
;;
;; result - stdout
;; ===================================================================
    _error_print:
        print_ptr   sep
        print_ptr   error_msg_part1

        mov         bx, offset buffer
        add         bx, cx
        add         bx, 1
        mov         bx, [bx]
        print_char  bl

        print_ptr   error_msg_part2

        mov         ax, cx
        call        print_dec
        print_ptr   error_msg_part3
        ret
;; ===================================================================


    include STRUTIL.ASM
    sep             db      0dh, 0ah, "$"
    error_msg_part1 db      "Found unexpected symbol '$"
    error_msg_part2 db      "' at $"
    error_msg_part3 db      " position.$"
    buffer          db      BUFFER_LENGTH dup (24h), "$"
    message         db      "Hello DOS $"
    numbers         db      "123$"

    end start