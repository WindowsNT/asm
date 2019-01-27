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

nop
rspsave dq 0
exitreason db 0
vregs dq 50 dup (0)


segment CODE64
USE64

include 'vdisplay.asm'

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

vmlaunch

hr:

; Save all volatile registers
push r15
linear r15,vregs,STACK64
mov [r15 + 0x00],rax
mov [r15 + 0x08],rbx
mov [r15 + 0x10],rcx
mov [r15 + 0x18],rdx
mov [r15 + 0x20],rsi
mov [r15 + 0x28],rdi
mov [r15 + 0x30],rbp
pop r15


; check exit reason
vmr rax,0x4402
cmp al,18
jnz DebugInterface

linear rax,firstcall,V
cmp byte [rax],1
je VmFinalCall
mov byte [rax],1
; rip +3
vmr rax,0x681E
add rax,3
vmw64 0x681E,rax
mov al,18
jmp DebugInterface



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

; al = reason

; Just resume yet, not ready
if VDEBUG = 0
	jmp DebugResume
end if

linear rdx,exitreason,STACK64
mov byte [rdx],al
call ShowDisplay
jmp DebugResume


DebugResume:
push r15
linear r15,vregs,STACK64
mov rax,[r15 + 0x00]
mov rbx,[r15 + 0x08]
mov rcx,[r15 + 0x10]
mov rdx,[r15 + 0x18]
mov rsi,[r15 + 0x20]
mov rdi,[r15 + 0x28]
mov rbp,[r15 + 0x30]
pop r15
vmresume