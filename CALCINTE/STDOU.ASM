print_ptr MACRO ptr
    mov     ah, 09h
    mov     dx, offset ptr
    int     21h
ENDM

print_char MACRO reg
    mov     ah, 02h
    mov     dl, reg
    int     21h
ENDM