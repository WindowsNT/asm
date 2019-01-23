FORMAT MZ
HEAP 0

; main
segment CODE16
USE16

start16:
	mov ax,0x4C00
	int 0x21

SEGMENT ENDS 
entry CODE16:start16


