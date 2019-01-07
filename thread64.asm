USE16 
include 'directlong.asm'

Thread64_1:

	thread64header
	db 066h
	db 0eah
	Thread64Ptr2 dd 0
	dw code64_idx


	USE64
Thread64_1a:

    linear r8,FromThread6
	mov byte [r8],1
	qunlock64 mut_1
	cli
	hlt


USE64