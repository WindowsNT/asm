; --------------------------------------- 32 bit APIC functions ---------------------------------------
USE32

include 'mutex32.asm'




;-------------------------------------------------------------------------------------------
; Function SendSIPI32f : Sends SIPI. EBX = CPU Index, EAX = linear
;-------------------------------------------------------------------------------------------		
SendSIPI32f:
	PUSHAD
	PUSH DS
	PUSH ES
	mov cx,page32_idx
	mov es,cx
	mov cx,data16_idx
	mov ds,cx
		
	XOR ECX,ECX
	; Spurious
	MOV EDI,[DS:LocalApic]
	ADD EDI,0x0F0
	MOV EDX,[ES:EDI]
	OR EDX,0x1FF
	MOV [ES:EDI],EDX
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
	push cs
	call SendIPI32

	; SIPI 1
	MOV ECX,0x05600
	OR ECX,ESI
	push cs
	call SendIPI32

	; SIPI 2
	MOV ECX,0x05600
	OR ECX,ESI
	push cs
	call SendIPI32
	POP ES
	POP DS
	POPAD
RETF


;-------------------------------------------------------------------------------------------
; Function SendIPI32 : Sends IPI. EBX = CPU Index, ECX = IPI
;-------------------------------------------------------------------------------------------		
SendIPI32: ; EBX = CPU INDEX, ECX = IPI
	PUSHAD
	; Lock Mutex		
	mov ax,mut_ipi
	push cs
	call qwaitlock32

	; Write it to 0x310
	; EBX is CPU INDEX
	; MAKE IT APIC ID
	xor eax,eax
	mov ax,cpusstructize
	mul bx
	add ax,cpus
	mov di,ax
	add di,4
	mov bl,[ds:di]
	MOV EDI,[DS:LocalApic]
	ADD EDI,0x310
	MOV EDX,[ES:EDI]
	AND EDX,0xFFFFFF
	XOR EAX,EAX
	MOV AL,BL
	SHL EAX,24
	OR EDX,EAX
	MOV [ES:EDI],EDX
		
		
	; Write it to 0x300
	MOV EDI,[DS:LocalApic]
	ADD EDI,0x300
	MOV [ES:EDI],ECX
	; Verify it got delivered
	.Verify:
	 PAUSE
	MOV EAX,[ES:EDI];
	SHR EAX,12
	TEST EAX,1
	JNZ .Verify
	; Write it to 0xB0 (EOI)
 
	MOV EDI,[DS:LocalApic]
	ADD EDI,0xB0
    MOV dword [ES:EDI],0
		
	; Release Mutex
	qunlock32 mut_ipi
	POPAD
RETF


