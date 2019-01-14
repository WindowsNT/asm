; --------------------------------------- int 0xF0 real ---------------------------------------

c16o dw 0
c16s dw 0
c16sts dw 0
c16sto dw 0

include 'directlong.asm'

Thread16C:

	thread16header STACK16T1,stack16t1_end

	mov ax,CODE16
	mov ds,ax
	mov ax,[c16sts]
	mov ss,ax
	mov ax,[c16sto]
	mov sp,ax

    mov ax,0x25F0
	mov dx,int16
	int 0x21
	

	mov ax,CODE16
	mov ds,ax
	call far dword [c16o]
	cli
	hlt
	hlt

if RESIDENT_OWN_PM_STACK > 0

Thread32P:	
	mov     ax,page32_idx          
	mov     ss,ax  
	; mov esp,xxxxxxxx
	db 0x66
	db 0xBC
	c32st dd 0 


else

	c32st dd 0 
Thread32P:	
	mov     ax,stack32_idx          
	mov     ss,ax                   
	mov     esp,stack32dmmi_end  

end if

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

if RESIDENT_OWN_LM_STACK > 0
Thread64P:	
	; mov rsp,xxxxxxxx
	;mov rsp,0x0000000012345678
	db 0x48
	db 0xC7
	db 0xC4
	c64st dd 0 
else
    c64st dd 0
Thread64P:
	linear rsp,stack64dmmi_end,STACK64
end if 

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

if RESIDENT_OWN_LM_STACK > 0
Thread64PV:	
	; mov rsp,xxxxxxxx
	;mov rsp,0x0000000012345678
	db 0x48
	db 0xC7
	db 0xC4
	cv64st dd 0 
else
    cv64st dd 0
Thread64PV:
	linear rsp,stack64dmmi_end,STACK64
end if 

	linear rax,idt_LM_start
	lidt [rax]
	mov ax,page64_idx
	mov ss,ax
	mov ds,ax
	mov es,ax

; ---- VMX

	; Existence test
	linear rbx,vmt1,DATA16
	mov byte [rbx],0

	; VMX Preparation
	linear rbx,vmt1,DATA16
	mov byte [rbx],1

	; VMX_Init
	linear rax,vvr1,CODE16
	push rax; for returning
	db 0x68; push
	cv64_vmxinit dd 0 
	ret
	vvr1:

	; VMX_Enable
	linear rax,vvr2,CODE16
	push rax; for returning
	db 0x68; push
	cv64_vmxenable dd 0 
	ret
	vvr2:

	; Load the revision
	linear rdi,VMXRevision,VMXDATA64
	mov ebx,[rdi];

	; Initialize the region
	linear rdi,VMXStructureData2,VMXDATA64
	mov rcx,[rdi];  Get address of data1
	mov rsi,rdi
	mov rdi,rcx
	mov [rdi],ebx ; // Put the revision
	VMCLEAR [rsi]
	mov [rdi],ebx ; // Put the revision
	VMPTRLD [rsi] 
	mov [rdi],ebx ; // Put the revision

	; EPT init
	linear rax,vvr7,CODE16
	push rax; for returning
	db 0x68; push
	cv64_vmxinitept dd 0 
	ret
	vvr7:

	; Controls init
	mov rdx,0x49
	linear rax,vvr6,CODE16
	push rax; for returning
	db 0x68; push
	cv64_vmxinitcontrols dd 0 
	ret
	vvr6:


	; Host Init
	push gs
	push fs
	linear rcx,vretxx,CODE16
	linear rax,vvr4,CODE16
	push rax; for returning
	db 0x68; push
	cv64_vmxinithost dd 0 
	ret
	vvr4:
	pop fs
	pop gs

	; Guest Init
	mov r8,raw32_idx
	mov r9,0
	linear r10,vmentry,CODE16
	linear rax,vvr5,CODE16
	push rax; for returning
	db 0x68; push
	cv64_vmxinitguest2 dd 0 
	ret
	vvr5:

	; The EPT initialization for the guest
	linear rax,PhysicalEptOffset64,DATA16
	mov rax,[rax]
	or rax,0 ; Memory Type 0
	or rax,0x18 ; Page Walk Length 3
	mov rbx,0x201A ; EPTP
	vmwrite rbx,rax
 
	; The Link Pointer -1 initialization
	mov rax,0xFFFFFFFFFFFFFFFF
	mov rbx,0x2800 ; LP
	vmwrite rbx,rax
 
	; One more RSP initialization of the host
	xor rax,rax
	mov rbx,0x6c14 ; RSP
	mov rax,rsp
	vmwrite rbx,rax

	VMLAUNCH
	jmp vretxx

	; Virtual Machine Here, Protected mode
	cv64vmode db 0 
USE32
	vmentry:


	; set the stack
	mov ax,page32_idx
	mov ss,ax

	; set the IDT
	linear ebx,idt_PM_start,DATA16
	lidt [ebx]

	; check mode
	linear ebx,cv64vmode,CODE16
	mov bh,[ebx]

	cmp bh,0
	jz vmode0 ; Real

	cmp bh,1
	jz vmode1 ; Protected

	cmp bh,2
	jz vmode2 ; Long

	vmcall; duh


	vmode2: ; long
	vmcall

	vmode0: ; real
	vmcall ; 

	vmode1:
		; mov esp,xxxxxxxx
		db 0xBC
		cv64vst1 dd 0 

		; call the address
		db  09ah 
		cv64 dd  0
		dw  vmx32_idx
	VMCALL 
USE64
	vretxx:

	; VMX_Disable
	linear rax,vvr3,CODE16
	push rax; for returning
	db 0x68; push
	cv64_vmxdisable dd 0 
	ret
	vvr3:

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
Thread64CV:
	thread64header
	db 066h
	db 0eah
	Thread64Ptr4 dd 0
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
			; GS:CX = Stack

			and ebx,0xFF
			mov ax,CODE16
			mov ds,ax
			mov [c16s],es
			mov [c16o],dx
			mov [c16sts],gs
			mov [c16sto],cx
			linear eax,Thread16C,CODE16
			call far CODE16:SendSIPIf
			IRET
		.n10:

		cmp al,1
		jnz .n11
			; BL = CPU
			; AL = 1 = Protected mode thread
			; EDX = Linear Address
			; ECX = Linear Stack

			and ebx,0xFF
			mov ax,CODE16
			mov ds,ax
			mov [c32],edx
			mov [c32st],ecx
			linear eax,Thread32C,CODE16
			call far CODE16:SendSIPIf
			IRET
		.n11:

		cmp al,2
		jnz .n12
			; BL = CPU
			; AL = 2 = Long mode thread
			; EDX = Linear Address
			; ECX = Linear Stack

			and ebx,0xFF
			mov ax,CODE16
			mov ds,ax
			mov [c64],edx
			mov [c64st],ecx
			linear eax,Thread64C,CODE16
			call far CODE16:SendSIPIf
			IRET
		.n12:

		cmp al,3
		jnz .n13
			; BL = CPU
			; AL = 3 = Virtualized Thread
			; BX = mode (Currently 1 only, PM mode)
			; EDX = Linear Address
			; ECX = Linear Stack
			; EDI = Virtualized Linear Stack

			mov ax,CODE16
			mov ds,ax
			mov [cv64],edx
			mov [cv64st],ecx
			;mov [cv64vst0],edi
			mov [cv64vst1],edi
			;mov [cv64vst2],edi
			mov [cv64vmode],bh
			and ebx,0xFF
			linear eax,Thread64CV,CODE16
			call far CODE16:SendSIPIf
			IRET
		.n13:

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

	; AH 4, call real mode interrupt
	; AL = INT NUM
	; BP = AX VALUE
	; CX,DX,SI,DI = Normal values
	; Upper ESI,EDI => DS and ES
	cmp ah,4
	jnz nr4

	push ds
	push es
	push ax

	; Mutex Lock
	mov ax,mut_i21
	call far CODE16:qwaitlock16
	
	push esi
	shr esi,16
	mov ds,si
	pop esi

	push edi
	shr edi,16
	mov es,di
	pop edi
	
	; Interrupt put
	pop ax
	mov [cs:inttr],al
	push ax

	cmp al,0
	jz skip1
	mov ax,bp
	db 0xCD
	inttr db 0
	skip1:

	pop ax
	pop es
	pop ds

	; Unlock
	qunlock16 mut_i21
	iret
nr4:


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
	and eax,7FFFFFFFh; Set PE=0
	mov     cr0,eax         
	db      0eah
	dw      .flush_ipq,CODE16
	.flush_ipq:
	mov     ax,STACK16 
	mov     ss,ax
	xor esp,esp
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
	cmp al,0
	jz skip2
	push bp
	pop ax
	push gs
	pop ds
	push fs
	pop es

	db 0xCD
	inttt db 0
	skip2:

	; And again protected
	; macro EnterProtected ofs32 = Start32,codeseg = code32_idx,noinits = 0
	EnterProtected  i4BackFromRM,code32_idx



TempBackLM:

	mov     eax,cr0         
	and     al,not 1        
	and eax,7FFFFFFFh; Set PE=0
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
	mov ax,STACK16S
	mov ss,ax
	xor esp,esp
	mov esp,stack16dmmi2_end
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
	cmp al,0
	jz skip3
	push bp
	pop ax
	push gs
	pop ds
	push fs
	pop es

	db 0xCD
	inttt2 db 0
	skip3:

	; and again long mode

	thread64header
	db 066h
	db 0eah
	Thread64Ptr3 dd 0
	dw code64_idx
