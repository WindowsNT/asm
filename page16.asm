; --------------------------------------- 16 bit Paging routines to map 1GB ---------------------------------------
USE16

; We will call this from real mode to enter long mode directly when needed

InitPageTableFor64:

	; a function to use 1GB pages
    pushad
	push es
	push gs
	mov ax,DATA16
	mov gs,ax
	mov esi,[gs:PhysicalPagingOffset64]

	
	; Put the PML4T to 0x0000, these are 512 entries, so it takes 0x1000 bytes
	; We only want the first PML4T 
	mov eax,esi
	add eax,0x1000 ; point it to the first PDPT
	or eax,3 ; Present, Readable/Writable
	mov [fs:esi + 0x0000],eax
			
	mov ecx,4 ; Map 4GB (512*1GB).  
	mov eax,0x83 ; Also bit 7
	mov edi,esi
	add edi,0x1000
	.lxf1:
	mov     [fs:edi],eax
	add     eax,1024*1024*1024
	add edi,8
	loop .lxf1

	pop gs
	pop es
	popad

retf


