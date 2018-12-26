; --------------------------------------- A20 line routines ---------------------------------------
USE16
WaitKBC:
	mov cx,0ffffh
A20L:
	in al,64h
	test al,2
	loopnz A20L
ret

EnableA20:
	call WaitKBC
	mov al,0d1h
	out 64h,al
	call WaitKBC
	mov al,0dfh
	out 60h,al
ret


EnableA20f:
	call WaitKBC
	mov al,0d1h
	out 64h,al
	call WaitKBC
	mov al,0dfh
	out 60h,al
retf


DisableA20:
	call WaitKBC
	mov al,0d1h
	out 64h,al
	call WaitKBC
	mov al,0ddh
	out 60h,al
ret

CheckA20:
    PUSH ax 
    PUSH ds
    PUSH es 

    XOR ax,ax 
    MOV ds,ax 
    NOT ax 
    MOV es,ax 
    MOV ah,[ds:0] 
    CMP ah,[es:10h] 
    JNZ A20_ON 

    CLI 
    INC ah 
    MOV [ds:0],ah 
    CMP [es:10h],ah 
    PUSHF 
    DEC ah 
    MOV [ds:0],ah 
    STI 
    POPF 
    JNZ A20_ON 

    CLC 
    POP es
    POP ds
    POP ax 
    RET 

A20_ON: 
    STC 
    POP es
    POP ds
    POP ax 
RET

