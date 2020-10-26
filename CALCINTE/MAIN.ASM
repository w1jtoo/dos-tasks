BUFFER_LENGTH = 255

model tiny
.code
    org 100h

;; ========================== ENTRY POINT ============================
    _start:
        jmp     start
;; ===================================================================
;; ========================== INCLUDE BLOCK
    include STRUTIL.ASM     ; include str utils
    include STDOU.ASM       ; include stdout macros
;; =========================
;; ========================== ENTRY POINT ============================
    start:
        ;; read line
        call    _read_line
        xor     dx, dx
        xor     cx, cx          ; contains sign

        mov     bx, (offset buffer + 2)
        _loop:
            mov     ax, [bx]

            cmp     al, 0dh
            je      _ret

            cmp     al, "+"
            je     _plus
            
            cmp     al, "-"
            je      _minus

            push    ax
            call    parse_dec          ; ax <- prased number

            cmp     cx, 0h
            je      _positive_sign
            jmp     _negative_sign

            _positive_sign:
                add     dx, ax
                pop     ax
                jmp     _loop

            _negative_sign:
                sub     dx, ax
                pop     ax
                jmp     _loop
 
       _ret:
            push    dx
            print_ptr   new_line
            pop     dx

            mov     ax, dx
            call    print_dec
            ret

    _to_error_print:
        call    _error_print
        ret

    _plus:
        inc     bx
        jmp     _loop

    _minus:
        not     cx
        inc     bx
        jmp _loop

    _read_line:
        mov     ah, 0Ah
        mov     dx, offset buffer
        int     21h
        ret

;; ========================= PRINT ERROR MSG =========================
;; cx - index with error
;;
;; result - stdout
;; ===================================================================
    _error_print:
        print_ptr   new_line
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

;; ========================== COSNTANTS ==============================
    new_line        db      0dh, 0ah, "$"
    error_msg_part1 db      "Found unexpected symbol '$"
    error_msg_part2 db      "' at $"
    error_msg_part3 db      " position.$"
;; ========================== STATIC VARABLES ========================
    buffer          db      BUFFER_LENGTH, BUFFER_LENGTH dup (24h), "$"
    buffer_end      dw      $

    end _start
