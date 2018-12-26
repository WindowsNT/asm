USE64

macro qlock64 trg
	{
	push rcx
	linear ecx,trg
	dec byte [ecx]
	pop rcx
	}

macro qunlock64 trg
	{
	push rcx
	linear ecx,trg
	cmp byte [ecx],0xFF
	jz .unlk
	inc byte [ecx]
	.unlk:
	pop rcx
	}

qwait64:
	; ax = target mutex in data16
	push rcx
	linear ecx,eax

	.Loop1:		
	CMP byte [ecx],0xff
	JZ .OutLoop1
	pause 
	JMP .Loop1
	.OutLoop1:
	
	pop rcx
ret


qwaitlock64:
	; ax = target mutex in data16
	push rbx
	push rcx
	linear ecx,eax

	.Loop1:		
	CMP byte [ecx],0xff
	JZ .OutLoop1
	pause 
	JMP .Loop1
	.OutLoop1:
	
	; Lock is free, can we grab it?
	mov bl,0xfe
	MOV AL,0xFF
	LOCK CMPXCHG [ecx],bl
	JNZ .Loop1 ; Write failed

	.OutLoop2: ; Lock Acquired

	pop rcx
	pop rbx
ret
