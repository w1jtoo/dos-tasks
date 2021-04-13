DEL     main.com 2 > NUL

TASM main.asm
TLINK /t main.obj
DEL     main.map 2 > NUL
DEL     main.obj 2 > NUL