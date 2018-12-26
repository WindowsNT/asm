USE16

Thread16:

	cli
	mov ax,DATA16
	mov ds,ax
	mov [FromThread1],1
	

	
	qunlock16 mut_1
	cli
	hlt
		

Thread16_2:

	cli
	mov ax,DATA16
	mov ds,ax
	mov [FromThread2],1

	;mov ax,STACK16T
	;mov ss,ax
	;mov sp,stack16t_end
	;mov     di,idt_RM_start
	;lidt    [di]
    ;sti 
	;mov dx,thr1
	;mov ax,0900h
	;int 21h
	;cli

	qunlock16 mut_1
	cli
	hlt
		
