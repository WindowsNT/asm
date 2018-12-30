USE16 

macro thread64header ofs,seg
{
	USE16 
	; Remember CPU starts in real mode
	db 4096 dup (144) ; // fill NOPs

	cli

	; Stack
	mov ax,STACK16T5
	mov ss,ax
	mov sp,stack16t5_end

	; A20
	call FAR CODE16:EnableA20f

	; Unreal
	call FAR CODE16:EnterUnreal

	; GDT and IDT
	mov ax,DATA16
	mov ds,ax
	call far CODE16:GDTInit
	call far CODE16:IDTInit
	mov bx,gdt_start
	lgdt [bx]

	; Save linear
	mov eax,seg
	shl eax,4
	add eax,ofs
	linear ebx,doo,CODE64
	mov [fs:ebx],eax

	; Prepare Paging
	call FAR CODE16:InitPageTableFor64

	; Spurious, APIC		
	MOV EDI,[DS:LocalApic]
	ADD EDI,0x0F0
	MOV EDX,[FS:EDI]
	OR EDX,0x1FF
	push dword 0
	pop fs
	MOV [FS:EDI],EDX

	MOV EDI,[DS:LocalApic]
	ADD EDI,0x0B0
	MOV dword [FS:EDI],0
	
	; Enter Long Mode
    mov eax, cr4
    bts eax, 5
    mov cr4, eax
    
	; Load new page table
   	mov ax,DATA16
	push gs
	mov gs,ax
	mov edx,[gs:PhysicalPagingOffset64]
	pop gs
    mov cr3,edx
    
	; Enable Long Mode
    mov ecx, 0c0000080h ; EFER MSR number. 
    rdmsr ; Read EFER.
    bts eax, 8 ; Set LME=1.
    wrmsr ; Write EFER.

	; Enable both PM and Paging to activate Long Mode from Real Mode
    mov eax, cr0 ; Read CR0.
    or eax,80000000h ; Set PE=1.
	or eax,1 ; Also PM=1
    mov cr0, eax ; Write CR0.
	nop
	nop
	nop

	; We are now in Long Mode / Compatibility mode
    ; Jump to an 64-bit segment to enable 64-bit mode
    db 066h
	db 0eah
	doo dd 0
    dw code64_idx

	
	qunlock16 mut_1
	cli
	hlt 
	hlt

}


Thread64_1:

	thread64header Thread64_1a,CODE64

	USE64
Thread64_1a:

    linear r8,FromThread6
	mov byte [r8],1
	qunlock64 mut_1
	cli
	hlt


USE64