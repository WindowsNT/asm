FORMAT MZ
HEAP 0

; data
segment DATA16
USE16

m1 db "Virtualization Debugger, (C) Chourdakis Michael",0x0D,0x0A,"$"

; main 32
segment CODE32
USE32

start32:


; Back to real mode
xor ecx,ecx
mov cx,CODE16
shl ecx,16
add ecx,back16
mov ax,0x0900
int 0xF0


; main 64
segment CODE64
USE64

start64:

; interrupts
lidt [eax]

; Back to real mode
xor rcx,rcx
mov cx,CODE16
shl rcx,16
add ecx,back16
mov ax,0x0900
int 0xF0

; main
segment CODE16
USE16

back16:

	; End
	mov ax,0x4C00
	int 0x21


start16:


	mov ax,DATA16
	mov ds,ax
	mov ax,0x0900
	mov dx,m1
	int 0x21

	; Enter Protected
	mov cx,CODE32
	shl ecx,4
	add ecx,start32
	mov ax,0x901
	;int 0xF0

	; Enter Long
	xor ecx,ecx
	mov cx,CODE64
	shl ecx,4
	add ecx,start64
	mov ax,0x0902
	int 0xF0


SEGMENT ENDS 
entry CODE16:start16


