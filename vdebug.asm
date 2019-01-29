FORMAT MZ
HEAP 0

include 'config.asm'
include 'struct.asm' 
   


; stack
segment STACK16
USE16 

dw 128 dup(0)
stre:

; data
segment DATA16
USE16

run db 0
psp dw 0
m1 db "Virtualization Debugger, (C) Chourdakis Michael - Set VDEBUG=1 to config.asm.",0x0D,0x0A,"$"
prg db "d:\debuggee.exe",0x0


dismpos dd 0
bbb LoadX 0,0,0,0,0,0,0

include 'vdebug64.asm'
include "reqdmmi.asm"


; main
segment CODE16
USE16

back16:

	; End
	cli
	mov ax,STACK16
	mov ss,ax
	mov eax,stre
	mov esp,eax
	sti
	mov ax,DATA16
	mov ds,ax
	mov es,ax
	mov ax,0x4C00
	int 0x21


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

	; dism pos
	mov ax,0x1401
	xor ecx,ecx
	xor edx,edx
	int 0xF0
	mov word [es:dismpos],si
	mov word [es:dismpos + 2],ds
	mov ax,DATA16
	mov ds,ax

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


