; --------------------------------------- int 0xF0 protected ---------------------------------------

int32:


	; AX 0, find interface
	cmp ax,0
	jnz .n0
		push ds
		mov ax,data16_idx
		mov ds,ax
		mov dl,[numcpus]
		pop ds
		mov ax,0xFACE
	IRETD
.n0:

	; AH 5, mutex functions
	cmp ah,5
	jnz .n5

		; Initialize mutex
		cmp al,0
		jnz .n50
			push fs
			mov bx,page32_idx
			mov fs,bx
			mov byte [fs:edi],0xFF
			pop fs
		iret
		.n50:

		; lock mutex
		cmp al,2
		jnz .n52
			push fs
			mov bx,page32_idx
			mov fs,bx
			dec byte [fs:edi]
			pop fs
		iret
		.n52:

		; unlock mutex
		cmp al,3
		jnz .n53
			push fs
			mov bx,page32_idx
			mov fs,bx
			cmp byte [fs:edi],0xFF
			jz .okl
				inc byte [fs:edi]
			.okl:
			pop fs
		iret
		.n53:

		; wait mutex
		cmp al,4
		jnz .n54
			
			push fs
			mov bx,page32_idx
			mov fs,bx
			.Loop1:		
			CMP byte [fs:edi],0xff
			JZ .OutLoop1
			pause 
			JMP .Loop1
			.OutLoop1:
			pop fs

		iret
		.n54:

	IRET


.n5:


nop
iretd