segment V
USE16

ve:


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

	; Trap Flag
;	pushf
;	pop ax
;	or ah, 1
;	push ax
;	popf

	retf



segment STACK64
USE64
stx dq 1024 dup(0)
ste:

segment CODE64
USE64

start64:

; interrupts
lidt [eax]
linear rsp,ste,STACK64

mov ax,0
int 0xF0

; Prepare the virtualization structures
mov ax,0x801
linear r8,hr,CODE64
mov r9,V
mov r10,ve
int 0xF0

; Also disallow INT 0x1 and INT 0x3 to handle breakpoints
;mov eax,0x840069F2
;bts eax,2
;vmw32 0x4002,eax

vmlaunch

hr:

; Disable VMX
mov ax,0x800
int 0xF0

; Back to real mode
cli
xor rcx,rcx
mov cx,CODE16
shl rcx,16
add ecx,back16
mov ax,0x0900
int 0xF0
