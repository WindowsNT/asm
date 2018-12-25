; --------------------------------------- 64 bit Code ---------------------------------------
SEGMENT CODE64 USE64
ORG 0h


macro break64
{
	xchg bx,bx
}

Start64:

    break64
	xor r8d,r8d
	mov rsp,stack64_end  
	push rax
	mov rax,0
	pop rax

	; access d64 using linear, ds not used
	xor rax,rax
	mov ax,DATA64
	shl rax,4
	add rax,d64
	mov byte [rax],1

	; Back to Compatibility Mode
	push code32_idx
	xor rcx,rcx
	mov ecx,Back32
	push rcx
	retf



