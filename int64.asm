; --------------------------------------- int 0xF0 long ---------------------------------------

int64:



	; AX 0, find interface
	cmp ax,0
	jnz .n0
		linear rax,numcpus,DATA16
		mov dl,[rax]
		mov rax,0xFACE
	IRETQ
.n0:


	; AH 5, mutex functions
	cmp ah,5
	jnz .n5

		; Initialize mutex
		cmp al,0
		jnz .n50
			mov byte [rdi],0xFF
		iretq
		.n50:

		; lock mutex
		cmp al,2
		jnz .n52
			dec byte [rdi]
		iretq
		.n52:

		; unlock mutex
		cmp al,3
		jnz .n53
			cmp byte [rdi],0xFF
			jz .okl
				inc byte [rdi]
			.okl:
		iretq
		.n53:

		; wait mutex
		cmp al,4
		jnz .n54
			
			.Loop1:		
			CMP byte [rdi],0xff
			JZ .OutLoop1
			pause 
			JMP .Loop1
			.OutLoop1:

		iretq
		.n54:

	IRETQ


.n5:

IRETQ