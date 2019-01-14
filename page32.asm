; --------------------------------------- Paging routines ---------------------------------------
USE32

InitPageTable32a:

  ; A more clean version of what we are doing.
  ; We map the entire 4GB address space (1024*1024*4096) See Through

	pushad
	push ds
	push es
	
	mov ax,data16_idx
	push gs
	mov gs,ax
	mov ebp,[gs:PhysicalPagingOffset32]
	pop gs
	mov ax,page32_idx
	mov ds,ax
	mov es,ax
 
	; Tables Clear
	mov edi,ebp
	mov ecx,2048
	xor eax,eax
	rep stosd
 
	; PageDir32 points to PageTables32
	; Create 1024 entries
	mov edi,ebp
	xor ecx,ecx
	LoopPageDir1:
	xor eax,eax
	mov eax,ebp
	add eax,4096
	shr eax,12 ; Get rid of lower 12 bits (4096 alignment)
	mov ebx,ecx
	add eax,ebx
	shl eax,12
	or al,7 ; Present, Writable, Everyone, 
	stosd
	inc ecx
	cmp ecx,1024
	jnz LoopPageDir1
 
 
	; PageTables32 create 1024 entries
	mov edi,ebp
	add edi,4096
	xor ecx,ecx
	LoopPageTables1:
 
	xor eax,eax
	mov eax,0 ; See-Through, so we start at 0
	add eax,ecx
	shl eax,12
	or al,7 ; Present, Writable, Everyone, 
	stosd
 
	inc ecx
	cmp ecx,1024
	jnz LoopPageTables1
 
	pop es
	pop ds
	popad
ret



InitPageTable642:
    pushad
    push ds
    push es

	mov ax,data16_idx
	push gs
	mov gs,ax
	mov esi,[gs:PhysicalPagingOffset64]
	pop gs

    mov ax,page64_idx
    mov ds,ax
    mov es,ax
    xor     eax, eax
    mov     edi,esi
    mov     ecx,03000h
    rep     stosb

    ;top level page table
    mov     eax, esi
	add eax,0x1000
    or              eax,3
    mov     [esi],eax
    mov     eax, esi
	add eax,0x2000
    or              eax,3
    mov     [esi + 0x1000],eax

    ;2MB pages to identity map the first 16MB ram
    mov     eax,1
    shl             eax,7
    or              eax,3
    mov     [esi + 0x2000],eax
    add     eax,0x200000
    mov     [esi + 0x2008],eax
    add     eax,0x200000
    mov     [esi + 0x2010],eax
    add     eax,0x200000
    mov     [esi + 0x2018],eax
    add     eax,0x200000
    mov     [esi + 0x2020],eax
    add     eax,0x200000
    mov     [esi + 0x2028],eax
    add     eax,0x200000
    mov     [esi + 0x2030],eax
    add     eax,0x200000
    mov     [esi + 0x2038],eax

    pop es
    pop ds
    popad 
ret


InitPageTable643:

	; a function to use 1GB pages
    pushad
	push es
	push gs
	mov ax,data16_idx
	mov gs,ax
	mov ax,page32_idx
	mov es,ax
	mov esi,[gs:PhysicalPagingOffset64]

    ; clear
    mov     edi,esi
	xor eax,eax
    mov     ecx,03000h
    rep     stosb

	; Put the PML4T to 0x0000, these are 512 entries, so it takes 0x1000 bytes
	; We only want the first PML4T 
	mov eax,esi
	add eax,0x1000 ; point it to the first PDPT
	or eax,3 ; Present, Readable/Writable
	mov [es:esi + 0x0000],eax
			
	mov ecx,4 ; Map 4GB (512*1GB).  
	mov eax,0x83 ; Also bit 7
	mov edi,esi
	add edi,0x1000
	.lxf1:
	mov     [es:edi],eax
	add     eax,1024*1024*1024
	add edi,8
	loop .lxf1

	pop gs
	pop es
	popad

ret
