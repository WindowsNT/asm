; --------------------------------------- 64 bit APIC functions ---------------------------------------
USE64


include 'mutex64.asm'




;-------------------------------------------------------------------------------------------
; Function SendSIPI64 : Sends SIPI. RBX = CPU Index, EAX = linear
;-------------------------------------------------------------------------------------------		
SendSIPI64:
break64
	PUSH RAX
	PUSH RBX
	PUSH RCX
	PUSH RDX
	PUSH RSI
	PUSH RDI
		
		
	linear rcx,LocalApic
	; Spurious
	MOV EDI,[rCX]
	ADD EDI,0x0F0
	MOV EDX,[EDI]
	OR EDX,0x1FF
	MOV [EDI],EDX

	; Vector
	.L1:
	MOV ECX,EAX
	TEST EAX,0xFFF
	JZ .L2
	INC EAX
	JMP .L1
	.L2:
	MOV ESI,EAX
	SHR ESI,12
	; Init
	MOV ECX,0x04500
	OR ECX,ESI
	call SendIPI64
	; SIPI 1
	MOV ECX,0x05600
	OR ECX,ESI
	call SendIPI64

	; SIPI 2
	MOV ECX,0x05600
	OR ECX,ESI
	call SendIPI64


	POP RDI
	POP RSI
	POP RDX
	POP RCX
	POP RBX
	POP RAX
RET


;-------------------------------------------------------------------------------------------
; Function SendIPI64 : Sends IPI. EBX = CPU Index, ECX = IPI
;-------------------------------------------------------------------------------------------		
SendIPI64: ; EBX = CPU INDEX, ECX = IPI
	PUSH RAX
	PUSH RBX
	PUSH RCX
	PUSH RDX
	PUSH RSI
	PUSH RDI

	; Lock Mutex		
    xor rax,rax
	mov ax,mut_ipi
	call qwaitlock64

	; Write it to 0x310
	; EBX is CPU INDEX
	; MAKE IT APIC ID
	xor eax,eax
	mov ax,cpusstructize
	mul bx
	add ax,cpus
	xor rdi,rdi
	mov di,ax
	add di,4
	linear esi,edi
	mov bl,[esi]
	linear ecx,LocalApic
	MOV EDI,[ecx]
	ADD EDI,0x310
	MOV EDX,[EDI]
	AND EDX,0xFFFFFF
	XOR EAX,EAX
	MOV AL,BL
	SHL EAX,24
	OR EDX,EAX
	MOV [EDI],EDX
		
		
	; Write it to 0x300
	MOV EDI,[ecx]
	ADD EDI,0x300
	MOV [EDI],ECX
	; Verify it got delivered
	.Verify:
	 PAUSE
	MOV EAX,[EDI];
	SHR EAX,12
	TEST EAX,1
	JNZ .Verify
	; Write it to 0xB0 (EOI)
 
	MOV EDI,[ecx]
	ADD EDI,0xB0
    MOV dword [EDI],0
		
	; Release Mutex
	qunlock64 mut_ipi

	POP RDI
	POP RSI
	POP RDX
	POP RCX
	POP RBX
	POP RAX
RET


