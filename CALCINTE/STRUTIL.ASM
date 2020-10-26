;; ====================== PRINT DECIMAL NUMBER =======================
;; ax - number
;;
;; result - stdout
;; ===================================================================
print_dec:
    xor cx, cx

    _pd_rep:
        xor     dx, dx
        mov     bx, 10
        div     bx          ; ax = dx:ax / bx, dx = dx:ax % bx

        add     dx, "0"

        push    dx
        inc     cx

        test    ax, ax
        jnz     _pd_rep

    _pd_prnt:
        pop     dx
        mov     ah, 02h     ; DOS function PrintChar(chr: dl)
        int     21h
        loop    _pd_prnt    ; if --cx > 0 then goto _pd_prnt

    ret
;; ===================================================================


;; ====================== PARSE DECIMAL NUMBER =======================
;;      bx - ptr to str
;;      cx - radix -- TODO
;;
;;      ax - result
;;      bx - index to last read symbol
;; ===================================================================
parse_dec:
    push    cx
    push    dx

    xor     dx, dx
    _rd_rep:
        mov     ax, [bx]

        cmp     al, "0"
        jb      _rd_ex      ; if al < "9" then exit

        cmp     al, "9"
        ja      _rd_ex      ; if al > "9" then exit

        ; dx *= 10
        mov     cx, dx
        sal     dx, 3       ; dx = 8dx(old)
        sal     cx, 1       ; cx = 2dx(old)
        add     dx, cx      ; dx = 10dx(old)

        sub     al, "0"
        xor     ah, ah
        add     dx, ax      ; dx += int(char_from_console)

        inc     bx
        jmp     _rd_rep

    _rd_ex:
        mov     ax, dx

    pop dx
    pop cx

    ret
;; ===================================================================
