FORMAT MZ
HEAP 0

macro linear reg,trg,seg = DATA16
	{
	mov reg,seg
	shl reg,4
	add reg,trg
	}

segment STACK16
USE16 

dw 128 dup(0)
stre:

segment DATA16
USE16
m1 db "Switcher, (C) Chourdakis Michael.",0x0D,0x0A,"$"

segment CODE16
USE16

include "reqdmmi.asm"

start16:
	mov ax,STACK16
	mov ss,ax
	mov eax,stre
	mov esp,eax
	mov ax,DATA16
	mov ds,ax
	mov es,ax
	mov ax,0x0900
	mov dx,m1
	int 0x21

	mov ax,0x4C00
	int 0x21

SEGMENT ENDS 
entry CODE16:start16


