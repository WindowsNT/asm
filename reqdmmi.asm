

macro RequireDMMI
{
	local FailX
	local SuccX
	local FailErr

	pushad
	push es
	push ds

	mov ax,0x35F0
	int 0x21
	cmp dword [es:bx + 2],'dmmi'
	jnz FailX
	mov ax,0
	int 0xF0
	cmp ax,0xFACE
	jnz FailX

	pop ds
	pop es
	popad
	jmp SuccX

	FailErr db "This app requires a DMMI Server",0xD,0xA,"$"
	FailX:
	push cs
	pop ds
	mov ax,0x0900
	mov dx,FailErr
	int 0x21
	pop ds
	pop es
	popad
	mov ax,0x4c00
	int 0x21

	SuccX:

}