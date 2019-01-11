; le-main, 32-bit flat, everything is inside here

jmp main

tx1b db 'Hello from protected mode, using DOS/32A, coded with FASM !!!',0x0D,0x0A,0x24

main:
	laddr edx,tx1b
	mov   ah,9
	int   0x21

    mov   ax,0x4C00
    int   0x21


