bits    16
org     0x100

%include    "src/utils/std.asm"
%include    "src/utils/macro.asm"
%define     ESC 1

fake_start:
    jmp     start

promt_start:    db "LOL"

read_key:
    int     0x16

start:
    call        read_key        ;; pressed key -> ax
    
    cmp         ax, ESC

    call        update_info
    PRINT_PRT   promt_start

    EXIT
