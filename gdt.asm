; --------------------------------------- GDT routines ---------------------------------------
USE16

macro gdt_initialize a_seg,a_desc
{
    xor eax,eax
	mov ax,a_seg
	shl eax,4
	mov [a_desc + 2],ax
    shr eax,8
    mov [a_desc + 4],ah 
}

macro gdt_initialize64 a_seg,a_desc
{
    xor eax,eax
	mov [a_desc + 2],ax
    mov [a_desc + 4],ah 
}

GDTInit:
	
	; 16-32 segments
	gdt_initialize CODE32,code32_descriptor
	gdt_initialize DATA32,data32_descriptor
	gdt_initialize STACK32,stack32_descriptor
	gdt_initialize CODE16,code16_descriptor
	gdt_initialize DATA16,data16_descriptor
	gdt_initialize STACK16,stack16_descriptor
	gdt_initialize 0,raw32_descriptor

    ; Paging segment, we 've found it already	
	xor eax,eax
    mov [ds:page32_descriptor.b0_15],ax
    mov [ds:page32_descriptor.b16_23],ah
	xor eax,eax
    mov [ds:page64_descriptor.b0_15],ax
    mov [ds:page64_descriptor.b16_23],ah


	; 64 segments
	gdt_initialize64 CODE64,code64_descriptor
	gdt_initialize64 DATA64,data64_descriptor


	; and the LDT
	xor eax,eax
	mov ax,DATA32
	shl eax,4           
	add eax,ldt_start
	mov [ds:ldt_descriptor.b0_15],ax
	shr eax,8
	mov [ds:ldt_descriptor.b16_23],ah
 
	; Set gdt ptr
	xor eax,eax
	mov ax,DATA16       
	shl eax,4
	add ax,dummy_descriptor
	mov [gdt_ptr],eax

RETF