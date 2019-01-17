; --------------------------------------- int 0xF0 protected ---------------------------------------

int32_21:

	mov bp,ax
	mov ax,0x0421

int32:


	jmp .ibegin
	db 'dmmi'
	.ibegin:
	; AX 0, find interface
	cmp ax,0
	jnz .n0

		dh_virtualization;
		push ds
		mov ax,data16_idx
		mov ds,ax
		mov dl,[numcpus]
		pop ds
		mov ax,0xFACE
	IRETD
.n0:


	; AH 4, call real mode interrupt
	; AL = INT NUM
	; BP = AX VALUE
	; CX,DX,SI,DI = Normal values
	; Upper ESI,EDI => DS and ES
	cmp ah,4
	jnz nn4

	push ds
	push eax

	mov ax,data32_idx
	mov ds,ax

	; Mutex Lock
	mov ax,mut_i21
	call far code32_idx:qwaitlock32

	; Save: AX,BX,CD,DX,SI,DI,DS,ES
	mov word [From32To16Regs],bp
	mov word [From32To16Regs + 2],bx
	mov word [From32To16Regs + 4],cx
	mov word [From32To16Regs + 6],dx
	mov word [From32To16Regs + 8],si
	mov word [From32To16Regs + 10],di
	mov eax,esi
	shr eax,16
	mov word [From32To16Regs + 12],ax
	mov eax,edi
	shr eax,16
	mov word [From32To16Regs + 14],ax
	pop eax
	mov byte [From32To16Regs + 16],al ; #intr
	mov word [From32To16Regs + 18],ss ; save for later
	mov dword [From32To16Regs + 20],esp ; save for later

	; back to real mode
    db		066h
	db      0eah
	dw      TempBackRM
	dw		code16_idx
	i4BackFromRM:
	mov ax,stack32_idx
	mov ss,ax
	mov ax,data32_idx
	mov ds,ax
	mov ax,word [From32To16Regs + 18]
	mov ss,ax
	mov esp,dword [From32To16Regs + 20]
	pop ds

	qunlock32 mut_i21

	iretd
nn4:


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
		iretd
		.n50:

		; lock mutex
		cmp al,2
		jnz .n52
			push fs
			mov bx,page32_idx
			mov fs,bx
			dec byte [fs:edi]
			pop fs
		iretd
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
		iretd
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

		iretd
		.n54:

	IRETd


.n5:


nop
iretd


CompatFromLongIntF0:

; Disable Paging to get out of Long Mode
	mov eax, cr0
	and eax,7fffffffh 
	mov cr0, eax
; Deactivate Long Mode
	mov ecx, 0c0000080h
	rdmsr
	btc eax, 8
	wrmsr
; Disable PAE
	mov eax, cr4
	btc eax, 5
	mov cr4, eax

; Go Real
    db		066h
	db      0eah
	dw      TempBackLM
	dw		code16_idx
