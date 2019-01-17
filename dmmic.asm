FORMAT MZ

include 'config.asm'

macro linear reg,trg,seg
	{
	xor reg,reg
	mov reg,seg
	shl reg,4
	add reg,trg
	}

macro rinear reg,trg,seg
	{
	xor reg,reg
	mov reg,seg
	shl reg,16
	add reg,trg
	}

; --- Thread Stacks
SEGMENT STACKS

stx1 dw 100 dup (?)
stx1e:

stx2 dw 100 dup(0)
stx2e:

stx3 dw 1000 dup(0)
stx3e:

stx4 dw 1000 dup(0)
stx4e:

stx5 dw 1000 dup(0)
stx5e:

stx6 dw 1000 dup(0)
stx6e:

stx7 dw 1000 dup(0)
stx7e:

stx8 dw 1000 dup(0)
stx8e:

stx9 dw 1000 dup(0)
stx9e:

nop


; ---- Unrestricted vm Mode Thread
SEGMENT T16 USE16

v0:

sti
mov si,MAIN16
shl esi,16
mov dx,m4
mov bp,0x0900
mov ax,0x0421
int 0xF0

; Unlock mutex
mov ax,MAIN16
mov es,ax
mov di,mut1
mov ax,0x0503
int 0xF0

vmcall


; ---- Protected Mode Thread
SEGMENT T32 USE32

rt2:

; Int 0xF0 works also in protected mode
mov ax,0
int 0xF0

; DOS call
mov bp,0x0900
xor esi,esi
mov si,MAIN16
shl esi,16
mov dx,m2 
mov ax,0x421
int 0xF0

; Unlock mutex
mov ax,0x0503
linear edi,mut1,MAIN16
int 0xF0

retf


; Virtualized PM Thread
v1:

; Int 0xF0 works also in protected mode
mov ax,0
int 0xF0

; DOS call
mov bp,0x0900
xor esi,esi
mov si,MAIN16
shl esi,16
mov dx,m1
mov ax,0x421
;int 0xF0 ;Not Yet

; Unlock mutex

mov ax,0x0503
linear edi,mut1,MAIN16
int 0xF0

retf



; ---- Long Mode Thread
SEGMENT T64 USE64

rt3:

nop
nop
nop
nop
nop

; Int 0xF0 works also in long mode
mov ax,0
int 0xF0

; DOS call
xor rsi,rsi
mov si,MAIN16
shl rsi,16
mov rdx,m3
mov rax,0x0900
int 0x21

; Unlock mutex
mov ax,0x0503
linear rdi,mut1,MAIN16
int 0xF0


ret

; Virtualized LM Thread
v2:

vmcall



SEGMENT MAIN16 USE16
ORG 0h

m0 db "DMMI server not installed. Run entry.exe with /r",0xd,0xa," $"
m1 db "Hello from real mode thread",0xd,0xa,"$";
m2 db "Hello from protected mode thread",0xd,0xa,"$";
m3 db "Hello from long mode thread",0xd,0xa,"$";
m4 db "Hello from unrestricted mode virtualized thread",0xd,0xa,"$";
mut1 db 0

; Real mode thread
rt1:

sti
push cs
pop si
shl esi,16
mov dx,m1
mov bp,0x0900
mov ax,0x0421
int 0xF0


; unlock mut
push cs
pop es
mov di,mut1
mov ax,0x0503
int 0xF0

retf



main:

if RESIDENT = 0
	mov ax,0x4c00
	int 0x21
end if

; Check if there first
mov ax,0x35F0
int 0x21
cmp dword [es:bx + 2],'dmmi'
jnz .f

mov ax,0
int 0xF0
cmp ax,0xFACE
jz .y

.f:
push cs
pop ds
mov ax,0x0900
mov dx,m0
int 0x21

mov ax,0x4c00
int 0x21


.y:
; dl = num of cpus

; enter unreal
mov ax,0x0900
int 0xF0

; init mut
push cs
pop es
mov di,mut1
mov ax,0x0500
int 0xF0

repeat 6
	; lock mut 
	push cs
	pop es
	mov di,mut1
	mov ax,0x0502
	int 0xF0
end repeat

; run a real mode thread
push cs
pop es
mov dx,rt1
mov cx,STACKS
mov gs,cx
mov cx,stx1e
mov ax,0x0100
mov ebx,1
int 0xF0

; run a real mode thread
push cs
pop es
mov dx,rt1
mov cx,STACKS
mov gs,cx
mov cx,stx2e
mov ax,0x0100
mov ebx,2
int 0xF0

; run a protected thread
push cs
pop es
mov ax,0x0101
mov ebx,3
linear ecx,stx3e,STACKS
linear edx,rt2,T32
int 0xF0

; run a long thread
push cs
pop es
mov ax,0x0102
mov ebx,4
linear ecx,stx4e,STACKS
linear edx,rt3,T64
int 0xF0

; run a protected thread
push cs
pop es
mov ax,0x0101
mov ebx,5
linear ecx,stx5e,STACKS
linear edx,rt2,T32
int 0xF0

; run a virtualized paged  protected mode thread
push cs
pop es
mov ax,0x0103
mov ebx,0x107
linear edi,stx6e,STACKS
linear ecx,stx7e,STACKS
linear edx,v1,T32
;int 0xF0

; run a virtualized real mode thread
push cs
pop es
mov ax,0x0103
mov ebx,0x007
rinear edi,stx8e,STACKS
linear ecx,stx9e,STACKS
rinear edx,v0,T16
int 0xF0

; wait mut
push cs
pop es
mov di,mut1
mov ax,0x0504
int 0xF0

mov ax,0x4c00
int 0x21

entry MAIN16:main