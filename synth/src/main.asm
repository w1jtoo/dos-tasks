bits    16
org     0x100

%include    "src/utils/std.asm"
%include    "src/utils/macro.asm"

start:
    call    init_int9

.ret:
    call    restore_int9
    EXIT

%include "src/keyboard_handler.asm"
