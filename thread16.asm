USE16

Thread16:

    sti 
	mov ax,DATA16
	mov ds,ax
	mov [FromThread1],1

	cli
	hlt
		