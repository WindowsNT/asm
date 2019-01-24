FORMAT MZ
HEAP 0

; main
segment CODE16
USE16

m1 db "Hello",0xD,0xA,"$"

start16:
    mov ax,CODE16
	mov ds,ax
	mov ax,0x0900
	mov dx,m1
	int 0x21

	mov ax,0x4C00
	int 0x21

SEGMENT ENDS 
entry CODE16:start16


