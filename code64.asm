; --------------------------------------- 64 bit Code ---------------------------------------
SEGMENT CODE64 USE64
ORG 0h

Start64:

	xor r8d,r8d
	mov rsp,stack64_end  
	push rax
	mov rax,0
	pop rax

	; Back to Compatibility Mode
	push code32_idx
	xor rcx,rcx
	mov ecx,Back32
	push rcx
	retf



