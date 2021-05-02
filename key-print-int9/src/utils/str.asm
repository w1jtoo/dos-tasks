%macro TO_HEX 1
    add     byte %1, '0'
    cmp     byte %1, '9'
    jna     %%ret

    add    %1, 'A'- '9' + 1
%%ret:
%endmacro