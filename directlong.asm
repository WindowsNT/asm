

macro thread64header brk=0
{
   local nobrk

	USE16 
	; Remember CPU starts in real mode
	db 4096 dup (144) ; // fill NOPs

	cli

	mov ax,brk
	cmp ax,1
	jnz nobrk
	xchg bx,bx
	nobrk:


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
	call far CODE16:IDTInit64
	mov bx,gdt_start
	lgdt [bx]


	; Prepare Paging
	nop
	nop
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

}
