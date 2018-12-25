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
	
	  xor eax,eax
      mov     ax,0       ; get 32-bit page segment into AX  = NOT PAGE32 = because it is assumed to be at 0!
      shl     eax,4           ; make a physical address
      xor     ebx,ebx
      mov     ebx,PageDir32
      add     ebx,eax
      mov     [ds:PhysicalPagingOffset32],ebx
      mov     [ds:page32_descriptor.b0_15],ax ; store it in the dscr
      shr     eax,8
      mov     [ds:page32_descriptor.b16_23],ah




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

RET