bits    16
org     0x100

%include    "src/utils/std.asm"
%include    "src/utils/macro.asm"

start:
    PRINT_STR "Hello, NASM and DOS!"
    EXIT
