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



	; AH 4, call real mode interrupt
	; AL = INT NUM
	; BP = AX VALUE
	; CX,DX,SI,DI = Normal values
	; Upper ESI,EDI => DS and ES


	cmp ah,4
	jnz nx4

	push rax
	linear r8,From64To16Regs,DATA64

	; Save: AX,BX,CD,DX,SI,DI,DS,ES
	mov word [r8],bp
	mov word [r8 + 2],bx
	mov word [r8 + 4],cx
	mov word [r8 + 6],dx
	mov word [r8 + 8],si
	mov word [r8 + 10],di
	mov eax,esi
	shr eax,16
	mov word [r8 + 12],ax
	mov eax,edi
	shr eax,16
	mov word [r8 + 14],ax
	pop rax
	mov byte [r8 + 16],al ; #intr
	mov word [r8 + 18],ss ; save for later
	mov dword [r8 + 20],esp ; save for later

	; go to compatibility mode
	push code32_idx
	xor rcx,rcx
	mov ecx,CompatFromLongIntF0
	push rcx
	retf

USE64
	BackFromExecutingInterruptLM:
	linear rsp,stack64dmmi_end,STACK64
	linear rax,idt_LM_start
	lidt [rax]
	mov ax,page64_idx
	mov ss,ax
	linear r8,From64To16Regs,DATA64
	xor rsp,rsp
	mov esp,dword [r8 + 20]

	iretq
nx4:


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