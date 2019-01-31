FORMAT MZ
HEAP 0


segment DATA16
USE16


; main
segment CODE16
USE16

error:

mov ax,0x4C00
int 0x21

	modesw	dd	0

start16:

	; A raw (not DOS32A) DPMI client
	xchg bx,bx
				
	mov	ax,1687h		; get address of DPMI host's
	int	2fh
	or	ax,ax			; exit if no DPMI host
	jnz	error
	mov	word [modesw],di
	mov	word [modesw+2],es
	or	si,si			; check private data area size
	jz .l1		     	; jump if no private data area

	mov	bx,si			; allocate DPMI private area
	mov	ah,48h			; allocate memory
	int	21h			    ; transfer to DOS
	jc error			; jump, allocation failed
	mov	es,ax			; let ES=segment of data area

.l1:
	mov	ax,0			; bit 0=0 indicates 16-bit app
	call [modesw]			; switch to protected mode
	jc error			; jump if mode switch failed
					; else we're in prot. mode now
	nop

	mov ax,0x4C00
	int 0x21

SEGMENT ENDS 
entry CODE16:start16


