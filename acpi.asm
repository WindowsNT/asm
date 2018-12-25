USE16

search_acpi_2:
; Try to find at EBDA (http://wiki.osdev.org/RSDP)

	xor ecx,ecx
	push ds
	mov ax,0
	push ax
	pop ds
	
	mov ax,[ds:040eh]
	push ax
	pop ds
	
	mov eax,[ds:0]
	mov ebx,[ds:4];

	cmp ebx,0x20525450
	jne acpi2_not_found	
	
	cmp eax,0x20445352
	jne acpi2_not_found	

	mov ecx,1

acpi2_not_found:
	pop ds
ret


; -----------------------------------------------------
; Search for ACPI Method 1
; -----------------------------------------------------
search_acpi:
	xor ecx,ecx
	push esi
	push ds
	mov dx,0xE000
	push dx
	pop ds
	mov esi, 0	; Root pointer is E000:0 = ABS 0xE0000
loop_acpi:
	lodsd
	push eax
	pop ebx
	lodsd
	
	cmp eax,0x20525450
	jne acpi_not_found	
	
	cmp ebx,0x20445352
	jne acpi_not_found	
	
	jmp acpi_found

acpi_not_found:
	add esi,8 ; ACPI is aligned on a 16-byte boundary, always
	cmp esi, 0	; >?
	je noACPI			
	jmp loop_acpi

noACPI:
	cmp dx,0xE000
	jne acpi_end
	mov dx,0xF000 ; Also in 0xF0000 range
	push dx
	pop ds
	mov esi,0
	jmp loop_acpi

acpi_found:

	
; Verify the checksum
	push esi
	xor ebx, ebx
	mov ecx, 20
	nextchecksum:
		lodsb				; Get a byte
		add bl, al			; Add it to the running total
		sub cl, 1
		cmp cl, 0
		jne nextchecksum
	pop esi
	cmp bl, 0
	je checksum_match
	add esi,8
	jmp loop_acpi		; Checksum failed

checksum_match:
; FOUND and checksum worked

	mov ecx,1
	
acpi_end:
	pop ds
	pop esi
	
ret	


