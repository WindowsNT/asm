FORMAT MZ
SEGMENT CODE16 USE16

m0 db "DMMI Client",0xd,0xa,"$";

MAIN:

    push cs
	pop ds
	mov ax,0x0900
	mov dx,m0
	int 0x21

    mov ax,0x4c00
	int 0x21


ENTRY CODE16:MAIN

