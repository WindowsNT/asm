USE16



macro lock16 trg,del = -1
	{
	push ds
	push di
	push ecx
	MOV DI,DATA16
	MOV DS,DI
	MOV DI,trg
	mov ecx,del
	call far CODE16:MutexLock16f
	pop ecx
	pop di
	pop ds
	}

macro unlock16 trg
	{
	push ds
	push di
	MOV DI,DATA16
	MOV DS,DI
	MOV DI,trg
	call far CODE16:MutexFree16f
	pop di
	pop ds
	}

macro qlock16 trg,del = -1
	{
	push ds
	push di
	push ecx
	MOV DI,DATA16
	MOV DS,DI
	MOV DI,trg
	mov byte  [ds:di],0xFE
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
	mov byte [ds:di],0xFF
	pop di
	pop ds
	}

macro wait16 trg
	{
	push ds
	push di
	MOV DI,DATA16
	MOV DS,DI
	MOV DI,trg
	call far CODE16:MutexWait16f
	pop di
	pop ds
	}

;-------------------------------------------------------------------------------------------
; Function MutexLock16f : DS:DI Mutex to lock
;-------------------------------------------------------------------------------------------		
MutexLock16f: ; DS:DI mutex to lock
	CMP byte [DS:DI],0xFE
	JNZ .np1
	retf
	.np1:

	pushadxeax
	PUSH CS
	CALL GetMyApic16f ; BL has the APIC
	MOV AL,0xFF
		
	.Loop1:		
	CMP [DS:DI],BL
	JZ .OutLoop2
	CMP [DS:DI],AL
	JZ .OutLoop1
	pause 
	cmp ecx,-1
	jz .nox
	dec ecx
	jecxz .locktimeout
	.nox:
	JMP .Loop1
		
	.locktimeout:
	mov eax,-1
	popadxeax
	retf
		
	.OutLoop1:

	; Lock is free, can we grab it?
	MOV AL,0xFF
	LOCK CMPXCHG [DS:DI],bl
	JNZ .Loop1 ; Write failed
	mov eax,1
	.OutLoop2: ; Lock Acquired

	popadxeax
	RETF


;-------------------------------------------------------------------------------------------
; Function MutexFree16f : DS:DI Mutex to free
;-------------------------------------------------------------------------------------------		
MutexFree16f: ; DS:DI mutex to lock
	CMP byte [DS:DI],0xFE
	JNZ .np1
	retf
	.np1:
	PUSHAD
	PUSH CS
	CALL GetMyApic16f ; BL has the APIC
	CMP [DS:DI],BL
	JNZ .Exit
	mov AL,0xFF
	MOV [DS:DI],AL
	.Exit:
	POPAD
	RETF

MutexWait16f:
			.Loop1:		
			CMP byte [ds:di],0xff
			JZ .OutLoop1
			pause 
			JMP .Loop1
			.OutLoop1:
			retf

