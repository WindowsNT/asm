main:

break16
mov ax,0
int 0xF0
cmp ax,0xFACE
jz .y
retf

.y:
mov ax,8
int 0xF0

retf

