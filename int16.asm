SEGMENT FO16 USE16

; --------------------------------------- int 0xF0 real ---------------------------------------

c16o dw 0
c16s dw 0

c32o dd 0

Thread16C:

	thread16header STACK16T1,stack16t1_end

	mov ax,CODE16
	mov ds,ax
    mov ax,0x25F0
	mov dx,int16
	int 0x21
	

	mov ax,CODE16
	mov ds,ax
	call far dword [c16o]
	cli
	hlt
	hlt


;Thread32C:

;	thread32header Thread32C,code32_idx

	cli
	hlt
	hlt


int16:

	; AX 0, find interface
	cmp ax,0
	jnz .n0
		push ds
		mov ax,DATA16
		mov ds,ax
		mov dl,[numcpus]
		pop ds
		mov ax,0xFACE
	IRET
.n0:

	; AH 1, begin thead
	cmp ah,1
	jnz .n1

	    cmp al,0
		jnz .n10
			; BL = CPU
			; AL = 0 = Unreal mode thread
			; ES:DX = Run address

			and ebx,0xFF
			mov ax,CODE16
			mov ds,ax
			mov [c16s],es
			mov [c16o],dx
			linear eax,Thread16C,CODE16
			call far CODE16:SendSIPIf

		.n10:

	    cmp al,1
		jnz .n11
			; BL = CPU
			; AL = 1 = Protected mode thread
			; EDX = Run address linesr

			and ebx,0xFF
			mov ax,CODE16
			mov ds,ax
			mov [c32o],edx
			linear eax,Thread32C,CODE16
			call far CODE16:SendSIPIf

		.n11:

	IRET


.n1:



	; AH 5, mutex functions
	cmp ah,5
	jnz .n5

		; Initialize mutex
		cmp al,0
		jnz .n50
			mov byte [es:di],0xFF
		iret
		.n50:

		; lock mutex
		cmp al,2
		jnz .n52
			dec byte [es:di]
		iret
		.n52:

		; unlock mutex
		cmp al,3
		jnz .n53
			cmp byte [es:di],0xFF
			jz .okl
				inc byte [es:di]
			.okl:
		iret
		.n53:

		; wait mutex
		cmp al,4
		jnz .n54
			
			.Loop1:		
			CMP byte [es:di],0xff
			JZ .OutLoop1
			pause 
			JMP .Loop1
			.OutLoop1:

		iret
		.n54:

	IRET


.n5:

IRET