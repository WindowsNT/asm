USE16

; Leaves FS in unreal mode
EnterUnreal:
	PUSHAD
	MOV AX,DATA16	
	MOV FS,AX
	linear eax,0,CODE16
	mov     [fs:code16_descriptorUNR.b0_15],ax ; store it in the dscr
	shr     eax,8
	mov     [fs:code16_descriptorUNR.b16_23],ah
	XOR eax,eax
	mov     [fs:data32_descriptorUNR.b0_15],ax ; store it in the dscr
	mov     [fs:data32_descriptorUNR.b16_23],ah
	; Set gdt ptr
	linear eax,dummy_descriptorUNR
	mov     [gdt_ptrUNR],eax
	mov bx,gdt_startUNR
	lgdt [fs:bx]
	mov eax,cr0
	or al,1
	mov cr0,eax 
	JMP $+2
	mov ax,10h
	mov fs,ax
	mov     eax,cr0         
	and     al,not 1        
	mov     cr0,eax         
	xor ax,ax
	mov fs,ax
	POPAD	
RETF
