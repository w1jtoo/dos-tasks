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
            mov     ax, [bx]            ; ax <- buffer[index]

            cmp     al, " "             ; if al is space => skip it
            je      _skip_char

            cmp     al, 0dh             ; if al is 0Bh => its end of line
            je      _ret

            cmp     al, "+"             ; if al is plus do nothing
            je     _plus

            cmp     al, "-"
            je      _minus              ; if al is minus cx ~= cx

            cmp     al, "0"             ; if al not dec in range
            jb      _to_error_print     ; print error

            cmp     al, "9"             ; al > '9' or al < '0'
            ja      _to_error_print     ; goto _to_error_print

            push    ax                  ; else parse number
            call    parse_dec           ; ax <- prased number

            cmp     cx, 0h              ; if cx >0
            je      _positive_sign      ; add result
            jmp     _negative_sign      ; sub result

            _positive_sign:
                add     dx, ax
                pop     ax
                jmp     _loop

            _negative_sign:
                sub     dx, ax
                pop     ax
                jmp     _loop

            _skip_char:
                inc     bx
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
;; bx - index with error
;;
;; result - stdout
;; ===================================================================
    _error_print:
        push        cx

        print_ptr   new_line                ; \n\r
        print_ptr   error_msg_part1         ; stdout <- "Found unexpected symbol '"
        mov         cx, bx                  ; cx <- ptr to buffer
        sub         cx, (offset buffer + 1) ; cx <- index of char = ptr to char - ptr to buffer + 1
                                            ; buffer[0] = 255 'couse of dos' buffer read

        mov         bx, [bx]                ; bx <- char at index
        print_char  bl                      ; stdout <- char

        print_ptr   error_msg_part2         ; stdout <- "' at "

        mov         ax, cx
        call        print_dec               ; stdout <- index
        print_ptr   error_msg_part3         ; stdout <- " position."

        pop cx
        ret

;; ========================== CONSTANTS ==============================
    new_line        db      0dh, 0ah, "$"
    error_msg_part1 db      "Found unexpected symbol '$"
    error_msg_part2 db      "' at $"
    error_msg_part3 db      " position.$"
;; ====================== STATIC VARIABLES ===========================
    buffer          db      BUFFER_LENGTH, BUFFER_LENGTH dup (24h), "$"
    buffer_end      dw      $

    end _start
