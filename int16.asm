; --------------------------------------- int 0xF0 real ---------------------------------------
int16:

	; AX 0, find interface
	cmp ax,0
	jnz .n0
		mov ax,0xFACE
	IRET
.n0:

	; AX 8, find num of cous
	cmp ax,8
	jnz .n8
		push ds
		mov ax,DATA16
		mov ds,ax
		mov al,[numcpus]
		pop ds
	IRET
.n8:


IRET