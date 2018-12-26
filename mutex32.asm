USE32





macro qlock32 trg
	{
	push ds
	push di
	push ecx
	MOV DI,data16_idx
	MOV DS,DI
	MOV DI,trg
	dec byte [ds:di]
	pop ecx
	pop di
	pop ds
	}

macro qunlock32 trg
	{
	push ds
	push di
	MOV DI,data16_idx
	MOV DS,DI
	MOV DI,trg
	cmp byte [ds:di],0xFF
	jz .unlk
	inc byte [ds:di]
	.unlk:
	pop di
	pop ds
	}

qwait32:
	; ax = target mutex in data16
	push ds
	push di
	MOV DI,data16_idx
	MOV DS,DI
	MOV DI,ax

	.Loop1:		
	CMP byte [ds:di],0xff
	JZ .OutLoop1
	pause 
	JMP .Loop1
	.OutLoop1:
	
	pop di
	pop ds
retf


qwaitlock32:
	; ax = target mutex in data16
	push bx
	push ds
	push di
	MOV DI,data16_idx
	MOV DS,DI
	MOV DI,ax

	.Loop1:		
	CMP byte [ds:di],0xff
	JZ .OutLoop1
	pause 
	JMP .Loop1
	.OutLoop1:
	
	; Lock is free, can we grab it?
	mov bl,0xfe
	MOV AL,0xFF
	LOCK CMPXCHG [DS:DI],bl
	JNZ .Loop1 ; Write failed

	.OutLoop2: ; Lock Acquired

	pop di
	pop ds
	pop bx
retf
