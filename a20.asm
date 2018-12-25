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


