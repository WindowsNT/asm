; --------------------------------------- 16 bit APIC functions ---------------------------------------
USE16

include 'mutex16.asm'


; Returns APIC in EBX
; implemented as FAR to allow calling from elsewhere
GetMyApic16f:
	push eax
	push ecx
	push edx
	mov eax,1
	cpuid
	and ebx,0xff000000
	shr ebx,24
	pop edx
	pop ecx
	pop eax
retf
	

;-------------------------------------------------------------------------------------------
; Function ChecksumValid : Check the sum. EDI physical addr, ECX count
;-------------------------------------------------------------------------------------------		
ChecksumValid:
	PUSH ECX
	PUSH EDI
	XOR EAX,EAX
	.St:
	ADD EAX,[FS:EDI]
	INC EDI
	DEC ECX
	JECXZ .End
	JMP .St
	.End:
	TEST EAX,0xFF
	JNZ .F
	MOV EAX,1
	.F:
	POP EDI
	POP ECX
	RETF

;-------------------------------------------------------------------------------------------
; Function FillACPI : Finds RDSP, and then RDST or XDST
;-------------------------------------------------------------------------------------------	
FillACPI:
	pushadxeax
	push es
	mov es,[fs:040eh]
	xor edi,edi
	mov di,[es:0]
	pop es
	mov edi, 0x000E0000	
	.s:
	cmp edi, 0x000FFFFF	; 
	jge .noACPI			; Fail.
	mov eax,[fs:edi]
	add edi,4
	mov edx,[fs:edi]
	add edi,4
	cmp eax,0x20445352
	jnz .s
	cmp edx,0x20525450
	jnz .s
	jmp .found
	.noACPI:
	popadxeax
	mov EAX,0xFFFFFFFF
RETF
	.found:

	; Found at EDI
	sub edi,8
	mov esi,edi
	; 36 bytes for ACPI 2
	mov ecx,36
	push cs
	call ChecksumValid
	cmp eax,1
	jnz .noACPI2
	mov eax,[fs:edi + 24]
	mov dword [ds:XsdtAddress],eax
	mov eax,[fs:edi + 28]
	mov dword [ds:XsdtAddress + 4],eax
	mov edi,dword [ds:XsdtAddress]
	mov eax,[fs:edi]
	cmp eax, 'XSDT'			; Valid?
	jnz .noACPI2
popadxeax
RETF
	.noACPI2:
	mov edi,esi
	mov ecx,20
	push cs
	call ChecksumValid
	cmp eax,1
	jnz .noACPI
	mov eax,[fs:edi + 16]
	mov dword [ds:XsdtAddress],eax
	mov edi,dword [ds:XsdtAddress]
	mov eax,[fs:edi]
	cmp eax, 'RSDT'			; Valid?
	jnz .noACPI

	mov edi,dword [ds:XsdtAddress]
	mov dword [ds:XsdtAddress],0
	mov dword [ds:RsdtAddress],edi

popadxeax
RETF


;-------------------------------------------------------------------------------------------
; Function FindACPITableX : Finds EAX Table,  edi is rsdt/xsdt address and ecx is 4 or 8
;-------------------------------------------------------------------------------------------		
FindACPITableX:
	cmp edi,0
	jz .f

	; len, must be more than 36
	mov ebx,[fs:edi + 4]
	cmp ebx,36
	jle .f
	sub ebx,36 
	xor edx,edx

	.loop:
	cmp edx,ebx
	jz .f
	mov esi,[fs:edi + 36 + edx]
	cmp eax,[fs:esi]
	jnz .c
	mov eax,esi
RETF
	.c:
	add edx,ecx
	jmp .loop
	.f:
	mov eax,0ffffffffh
RETF

	
;-------------------------------------------------------------------------------------------
; Function DumpMadt : Fills from  EAX MADT
;-------------------------------------------------------------------------------------------		
DumpMadt: ; EAX
		
	pushad
	mov edi,eax
	mov [ds:numcpus],0

	mov ecx,[fs:edi + 4] ; length
	mov eax,[fs:edi + 0x24] ; Local APIC 
	mov [ds:LocalApic],eax

	add edi,0x2C
	sub ecx,0x2C
	.l1:
			
		xor ebx,ebx
		mov bl,[fs:edi + 1] ; length
		cmp bl,0
		jz .end ; duh
		sub ecx,ebx
			
		mov al,[fs:edi] ; type
		cmp al,0
		jnz .no0
			
		; This is a CPU!
		xor eax,eax
		mov al,[ds:numcpus]
		inc [ds:numcpus]
		mov edx,cpusstructize
		mul edx
		xor esi,esi
		mov si,cpus
		add esi,eax
		mov al,[fs:edi + 2]; ACPI id
		mov byte [ds:si],al
		mov al,[fs:edi + 3]; APIC id
		mov byte [ds:si + 4],al
			

		.no0:
			
		add edi,ebx
		
	jecxz .end
	jmp .l1
	.end:
		
	popad
RETF


;-------------------------------------------------------------------------------------------
; Function DumpAll ; edi = xsdt or rsdt
;-------------------------------------------------------------------------------------------		
DumpAll:

mov ebp, 32 ; max count
	cmp edi,0
	jz .f

	; len, must be more than 36
	mov ebx,[fs:edi + 4]
	cmp ebx,36
	jle .f
	sub ebx,36 
	xor edx,edx

	.loop:
	cmp edx,ebx
	jz .f
	mov esi,[fs:edi + 36 + edx]
	mov eax,[fs:esi]

		; eax to show
	push edx
	mov edx,eax
	mov ah,2
	int 21h

	shr edx,8
	mov ah,2
	int 21h
	
	shr edx,8
	mov ah,2
	int 21h

	shr edx,8
	mov ah,2
	int 21h
	
	mov dl,' ';
	mov ah,2
	int 21h

	pop edx

	add edx,ecx

	dec ebp
	cmp ebp, 0
	jz .f

	jmp .loop
	.f:
RETF







;-------------------------------------------------------------------------------------------
; Function SendSIPIf : Sends SIPI. EBX = CPU Index, EAX = linear
;-------------------------------------------------------------------------------------------		
SendSIPIf:
	PUSHAD
	PUSH DS
	mov cx,DATA16
	mov ds,cx
		
	XOR ECX,ECX
	; Spurious
	MOV EDI,[DS:LocalApic]
	ADD EDI,0x0F0
	MOV EDX,[FS:EDI]
	OR EDX,0x1FF
	MOV [FS:EDI],EDX
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
	call SendIPI16
	; Delay 10 ms  = 0,01 s = (100 Hz)
	; 1193182/100
;		sleep16 11931
	MOV AH,86H
	MOV CX,0
	MOV DX,10*1000 ;10 ms
	INT 15H
	; SIPI 1
	MOV ECX,0x05600
	OR ECX,ESI
	push cs
	call SendIPI16
	; Delay 200 us = 0,2 ms = 0,0002 s = (5000 Hz)
	; 1193182/5000
;		sleep16 238
	MOV AH,86H
	MOV CX,0
	MOV DX,200 ; 200us
	INT 15H
	; SIPI 2
	MOV ECX,0x05600
	OR ECX,ESI
	push cs
	call SendIPI16
	POP DS
	POPAD
RETF


;-------------------------------------------------------------------------------------------
; Function SendIPI16 : Sends IPI. EBX = CPU Index, ECX = IPI
;-------------------------------------------------------------------------------------------		
SendIPI16: ; EBX = CPU INDEX, ECX = IPI
	PUSHAD
	; Lock Mutex		
	qlock16 mut_ipi

		
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
	MOV EDX,[FS:EDI]
	AND EDX,0xFFFFFF
	XOR EAX,EAX
	MOV AL,BL
	SHL EAX,24
	OR EDX,EAX
	MOV [FS:EDI],EDX
		
		
	; Write it to 0x300
	MOV EDI,[DS:LocalApic]
	ADD EDI,0x300
	MOV [FS:EDI],ECX
	; Verify it got delivered
	.Verify:
	 PAUSE
	MOV EAX,[FS:EDI];
	SHR EAX,12
	TEST EAX,1
	JNZ .Verify
	; Write it to 0xB0 (EOI)
 
	MOV EDI,[DS:LocalApic]
	ADD EDI,0xB0
    MOV dword [FS:EDI],0
		
	; Release Mutex
	qunlock16 mut_ipi
	POPAD
RETF


;-------------------------------------------------------------------------------------------
; Function SendEOI16 : Sends EOI
;-------------------------------------------------------------------------------------------		
SendEOI16: 
	PUSH EDI
	PUSH DS
	mov di,DATA16
	mov ds,di
	; Write it to 0xB0 (EOI)
;		MOV EDI,0xFEE00000
	MOV EDI,[DS:LocalApic]
	ADD EDI,0xB0
	MOV dword [FS:EDI],0
	POP DS
	POP EDI
RETF

; 
IntCompletedFunction:
	push ax
	push ds
	mov ax,DATA16
	mov ds,ax
	.iii:
		jecxz .liii
		cmp ecx,-1
		jz .nliii
		dec ecx
		.nliii:
		pause
		cmp [ds:IntCompleted],1
		jnz .iii
	.liii:
	pop ds
	pop ax
	.endiii:
RETF