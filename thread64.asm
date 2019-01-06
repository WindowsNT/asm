USE16 
include 'directlong.asm'

Thread64_1:

	thread64header Thread64_1a,CODE64

	USE64
Thread64_1a:

    linear r8,FromThread6
	mov byte [r8],1
	qunlock64 mut_1
	cli
	hlt


USE64