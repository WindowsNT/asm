FORMAT MZ
HEAP 0

include 'struct.asm'



; stack
segment STACK16
USE16

dw 128 dup(0)
stre:

dw 128 dup(0)
stx1e:

; data
segment DATA16
USE16

run db 0
psp dw 0
m1 db "Multicore Debugger, (C) Chourdakis Michael",0x0D,0x0A,"$"
prg db "d:\debuggee.exe",0x0

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

mut0 db 0


; main
segment CODE16
USE16

include "mdebugcore.asm"
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

	RequireDMMI

	; enter unreal
	mov ax,0x0900
	int 0xF0



	; Load executable
	mov bx,bbb
	mov dx,prg
	mov ax,0x4B01
	int 0x21
	jc endx
	BackExecutable:
	mov ax,DATA16
	mov ds,ax
	cmp [run],1
	je endx2
	mov [run],1
	mov ah,0x62
	int 0x21
	mov [psp],bx


	; mutexes
	mov ax,DATA16
	mov es,ax
	mov ax,0x0500
	mov di,mut0
	int 0xF0

	mov ax,DATA16
	mov es,ax
	mov ax,0x0502
	mov di,mut0
	int 0xF0

	; start thread
	mov ax,CODE16
	mov es,ax
	mov dx,Thr
	mov ax,0x0100
	mov bl,1
	mov cx,STACK16
	mov gs,cx
	mov cx,stx1e
	int 0xF0

	; run
	mov ax,DATA16
	mov ds,ax
	mov ax,[bbb.sp]
	mov sp,ax
	mov ax,[bbb.ss]
	mov ss,ax
	mov ax,[bbb.ip]
	push ax
	mov ax,[bbb.cs]
	push ax
	retf


	endx2:

	; wait mutex
	mov ax,DATA16
	mov es,ax
	mov ax,0x0504
	mov di,mut0
	int 0xF0


	endx:

	
	
	; End
	mov ax,0x4C00
	int 0x21




SEGMENT ENDS 
entry CODE16:start16


