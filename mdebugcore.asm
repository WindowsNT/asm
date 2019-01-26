

Thr:

	; mutex release
	mov ax,DATA16
	mov es,ax
	mov ax,0x0503
	mov di,mut0
	int 0xF0



retf
