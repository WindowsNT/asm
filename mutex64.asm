USE64

macro qlock64 trg
	{
	push rcx
	linear rcx,trg
	dec byte [rcx]
	pop rcx
	}

macro qunlock64 trg
	{
	push rcx
	linear rcx,trg
	cmp byte [rcx],0xFF
	jz .unlk
	inc byte [rcx]
	.unlk:
	pop rcx
	}

qwait64:
	; ax = target mutex in data16
	push rcx
	linear rcx,rax

	.Loop1:		
	CMP byte [rcx],0xff
	JZ .OutLoop1
	pause 
	JMP .Loop1
	.OutLoop1:
	
	pop rcx
ret


qwaitlock64:
	; rax = target mutex in data16
	push rbx
	push rcx
	linear rcx,rax

	.Loop1:		
	mov al,[rcx]
	CMP al,0xff
	JZ .OutLoop1
	pause 
	JMP .Loop1
	.OutLoop1:
	
	; Lock is free, can we grab it?
	mov bl,0xfe
	MOV AL,0xFF
	LOCK CMPXCHG [rcx],bl
	JNZ .Loop1 ; Write failed

	.OutLoop2: ; Lock Acquired

	pop rcx
	pop rbx
ret
