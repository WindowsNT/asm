segment V
USE16

firstcall db 0

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
	vmcall ; first call
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

; Also disallow INT 0x1 for first break
vmw32 0x4004,2
vmlaunch

hr:

; check exit reason
vmr32 rax,0x4402
cmp al,18
jz VmCallExit

jmp DebugInterface

VmCallExit:

linear rax,firstcall,V
cmp byte [rax],1
je VmFinalCall
mov byte [rax],1
; rip +3
vmr32 rax,0x681E
add rax,3
vmw64 0x681E,rax
vmw32 0x4004,0
; reset trap flag
vmr32 rax,0x6820
btr rax,8
vmw64 0x6820,rax
vmresume


VmFinalCall:
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

DebugInterface:



vmresume