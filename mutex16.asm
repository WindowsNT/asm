USE16





macro qlock16 trg,del = -1
	{
	push ds
	push di
	push ecx
	MOV DI,DATA16
	MOV DS,DI
	MOV DI,trg
	dec byte [ds:di]
	pop ecx
	pop di
	pop ds
	}

macro qunlock16 trg
	{
	push ds
	push di
	MOV DI,DATA16
	MOV DS,DI
	MOV DI,trg
	cmp byte [ds:di],0xFF
	jz .unlk
	inc byte [ds:di]
	.unlk:
	pop di
	pop ds
	}

macro qwait16 trg
	{
	local .Loop1
	local .OutLoop1
	push ds
	push di
	MOV DI,DATA16
	MOV DS,DI
	MOV DI,trg

	.Loop1:		
	CMP byte [ds:di],0xff
	JZ .OutLoop1
	pause 
	JMP .Loop1
	.OutLoop1:
	
	pop di
	pop ds
	}


