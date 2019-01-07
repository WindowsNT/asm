; --------------------------------------- int 0xF0 real ---------------------------------------

c16o dw 0
c16s dw 0

include 'directlong.asm'

Thread16C:

	thread16header STACK16T1,stack16t1_end

	mov ax,CODE16
	mov ds,ax
	mov     ax,STACK16
	mov     ss,ax     
	mov sp,stack16dmmi_end
    mov ax,0x25F0
	mov dx,int16
	int 0x21
	

	mov ax,CODE16
	mov ds,ax
	call far dword [c16o]
	cli
	hlt
	hlt

Thread32P:
	
	mov     ax,stack32_idx          
	mov     ss,ax                   
	mov     esp,stack32dmmi_end  
	mov ax,code16_idx
	mov ds,ax
	db  066h  
	db  09ah 
	c32 dd  0
	dw  vmx32_idx
    cli
	hlt
	hlt

USE64
Thread64P:

	linear rsp,stack64dmmi_end,STACK64
	linear rax,idt_LM_start
	lidt [rax]
	mov ax,page64_idx
	mov ss,ax

	linear rax,retx,CODE16
	push rax; for returning

	db 0x68; push
	c64 dd 0 
	ret
	retx:
	cli
	hlt
	hlt


USE16
Thread32C:
	thread16header STACK16T1,stack16t1_end
	EnterProtected Thread32P,code16_idx
Thread64C:
	thread64header
	db 066h
	db 0eah
	Thread64Ptr1 dd 0
	dw code64_idx



int16:

	jmp .ibegin
	db 'dmmi'
	.ibegin:
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
			IRET
		.n10:

		cmp al,1
		jnz .n11
			; BL = CPU
			; AL = 1 = Protected mode thread
			; EDX = Linear Address

			and ebx,0xFF
			mov ax,CODE16
			mov ds,ax
			mov [c32],edx
			linear eax,Thread32C,CODE16
			call far CODE16:SendSIPIf
			IRET
		.n11:

		cmp al,2
		jnz .n12
			; BL = CPU
			; AL = 2 = Long mode thread
			; EDX = Linear Address

			and ebx,0xFF
			mov ax,CODE16
			mov ds,ax
			mov [c64],edx
			linear eax,Thread64C,CODE16
			call far CODE16:SendSIPIf
			IRET
		.n12:

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


	; AX 9, switch to mode
	cmp ah,9
	jnz .n9

		; AL 0, unreal
		cmp al,0
		jnz .n90

			push cs
			cli
			call EnterUnreal
			sti
			IRET
			

		.n90:
	IRET
.n9:


IRET

TempBackRM:


	mov     eax,cr0         
	and     al,not 1        
	mov     cr0,eax         
	db      0eah
	dw      .flush_ipq,CODE16
	.flush_ipq:
	mov     ax,STACK16 
	mov     ss,ax
	mov     sp,stack16dmmi2_end
	mov ax, DATA16
	mov     ds,ax
	mov     es,ax
	mov     di,idt_RM_start
	lidt    [di]
	sti

	; execute the interrupt
	mov ax,DATA32
	mov ds,ax
	mov bp,word [From32To16Regs]
	mov bx,word [From32To16Regs + 2]
	mov cx,word [From32To16Regs + 4]
	mov dx,word [From32To16Regs + 6]
	mov si,word [From32To16Regs + 8]
	mov di,word [From32To16Regs + 10]
	mov ax, word [From32To16Regs + 12]
	mov gs,ax ; later DS
	mov ax, word [From32To16Regs + 14]
	mov fs,ax ; later ES
	mov al, byte [From32To16Regs + 16]
	mov [cs:inttt],al
	push bp
	pop ax
	push gs
	pop ds
	push fs
	pop es

	db 0xCD
	inttt db 0

	; And again protected
	; macro EnterProtected ofs32 = Start32,codeseg = code32_idx,noinits = 0
	EnterProtected  i4BackFromRM,code32_idx



TempBackLM:

	mov     eax,cr0         
	and     al,not 1        
	mov     cr0,eax         
	db      0eah
	dw      .flush_ipq,CODE16
	.flush_ipq:
	mov     ax,STACK16 
	mov     ss,ax
	mov     sp,stack16dmmi2_end
	mov ax, DATA16
	mov     ds,ax
	mov     es,ax
	mov     di,idt_RM_start
	lidt    [di]

	push cs
	call EnterUnreal

	sti

	; execute the interrupt
	mov ax,DATA64
	mov ds,ax
	mov bp,word [From64To16Regs]
	mov bx,word [From64To16Regs + 2]
	mov cx,word [From64To16Regs + 4]
	mov dx,word [From64To16Regs + 6]
	mov si,word [From64To16Regs + 8]
	mov di,word [From64To16Regs + 10]
	mov ax, word [From64To16Regs + 12]
	mov gs,ax ; later DS
	mov ax, word [From64To16Regs + 14]
	mov fs,ax ; later ES
	mov al, byte [From64To16Regs + 16]
	mov [cs:inttt2],al
	push bp
	pop ax
	push gs
	pop ds
	push fs
	pop es

	jmp fdg
	db 0xCD
	inttt2 db 0
	fdg:
	; and again long mode

	thread64header
	db 066h
	db 0eah
	Thread64Ptr3 dd 0
	dw code64_idx
