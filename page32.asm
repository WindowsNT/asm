; --------------------------------------- Paging routines ---------------------------------------
USE32

InitPageTable32a:

  ; A more clean version of what we are doing.
  ; We map the entire 4GB address space (1024*1024*4096) See Through

	pushad
	push ds
	push es
	mov ax,page32_idx
	mov ds,ax
	mov es,ax
 
	; PageDir32 Clear
	mov edi,PageDir32
	mov ecx,1024
	xor eax,eax
	rep stosd
 
	; PageTables32 Clear
	mov edi,PageTables32
	mov ecx,1024
	xor eax,eax
	rep stosd
 
	; PageDir32 points to PageTables32
	; Create 1024 entries
	mov edi,PageDir32
	xor ecx,ecx
	LoopPageDir1:
	xor eax,eax
	mov eax,PageTables32
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
	mov edi,PageTables32
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
    mov ax,page64_idx
    mov ds,ax
    mov es,ax
    xor     eax, eax
    mov     edi,LONGPAGEORGBASE
    mov     ecx,03000h
    rep     stosb

    ;top level page table
    mov     eax, LONGPAGEORGBASE + 0x1000
    or              eax,3
    mov     [LONGPAGEORGBASE],eax
    mov     eax, LONGPAGEORGBASE + 0x2000
    or              eax,3
    mov     [LONGPAGEORGBASE + 0x1000],eax

    ;2MB pages to identity map the first 16MB ram
    mov     eax,1
    shl             eax,7
    or              eax,3
    mov     [LONGPAGEORGBASE + 0x2000],eax
    add     eax,0x200000
    mov     [LONGPAGEORGBASE + 0x2008],eax
    add     eax,0x200000
    mov     [LONGPAGEORGBASE + 0x2010],eax
    add     eax,0x200000
    mov     [LONGPAGEORGBASE + 0x2018],eax
    add     eax,0x200000
    mov     [LONGPAGEORGBASE + 0x2020],eax
    add     eax,0x200000
    mov     [LONGPAGEORGBASE + 0x2028],eax
    add     eax,0x200000
    mov     [LONGPAGEORGBASE + 0x2030],eax
    add     eax,0x200000
    mov     [LONGPAGEORGBASE + 0x2038],eax

    pop es
    pop ds
    popad 
ret


