; --------------------------------------- 16 bit APIC functions ---------------------------------------
USE16

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


FillACPI:
	PUSHAD
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
	POPAD
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
	POPAD
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
	POPAD
RETF
		
;-------------------------------------------------------------------------------------------
; Function FindACPITable : Finds EAX Table
;-------------------------------------------------------------------------------------------		
FindACPITable:
	; EAX = sig
	push edi
	push ebx
	push edx
	mov edi,dword [ds:XsdtAddress]
	.l1:
	mov ebx,[fs:edi]
	mov edx,[fs:edi + 4]
	cmp edx,0
	jnz .ok1
	mov EAX,0xFFFFFFFF
	pop edx
	pop ebx
	pop edi
	RETF
	.ok1:
	cmp ebx,eax
	jz .f1
	add edi,edx
	jmp .l1
	.f1:
	mov eax,edi
	pop edx
	pop ebx
	pop edi
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
