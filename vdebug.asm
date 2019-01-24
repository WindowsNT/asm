FORMAT MZ
HEAP 0

include 'struct.asm'


; data
segment DATA16
USE16

run db 0
psp dw 0
m1 db "Virtualization Debugger, (C) Chourdakis Michael",0x0D,0x0A,"$"
prg db "d:\vdebug2.exe",0x0

struc LoadX a,b,c,d,e,f,g
    {
    .f1 dw a
    .f2 dd b
    .f3 dd c
	.f4 dd d
	.sp dw g
	.ss dw f
	.cs dw e
	.ip dw e
    }



bbb LoadX 0,0,0,0,0,0,0

include 'vdebug64.asm'

; main
segment CODE16
USE16

back16:

	; End
	xchg bx,bx
	mov ax,DATA16
	mov ds,ax
	mov es,ax
	mov ax,0x00
	int 0x21


start16:

	; End, not yet working
	mov ax,0x4C00
	int 0x21

	mov ax,DATA16
	mov ds,ax
	mov es,ax
	mov ax,0x0900
	mov dx,m1
	int 0x21


	; Load executable
	mov bx,bbb
	mov dx,prg
	mov ax,0x4B01
	int 0x21
	jc endx
	mov ax,DATA16
	mov ds,ax
	cmp [run],1
	je endx2
	mov [run],1
	mov ah,0x62
	int 0x21
	mov [psp],bx

	; Enter Long
	xor ecx,ecx
	mov cx,CODE64
	shl ecx,4
	add ecx,start64
	mov ax,0x0902
	int 0xF0

	endx2:
	vmcall


	endx:

	
	; End
	mov ax,0x4C00
	int 0x21




SEGMENT ENDS 
entry CODE16:start16


