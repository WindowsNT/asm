USE16 

macro thread32header ofs,seg
{
	; Remember CPU starts in real mode
	db 4096 dup (144) ; // fill NOPs
	break16
	
	CLI

	; A20
	call FAR CODE16:EnableA20f

	; Unreal
	call FAR CODE16:EnterUnreal
	
	; Spurious, APIC		
	MOV EDI,[DS:LocalApic]
	ADD EDI,0x0F0
	MOV EDX,[FS:EDI]
	OR EDX,0x1FF
	push dword 0
	pop fs
	MOV [FS:EDI],EDX

	MOV EDI,[DS:LocalApic]
	ADD EDI,0x0B0
	MOV dword [FS:EDI],0

	; Protected
	EnterProtected ofs,seg

}

USE16


Thread32_1:

	thread16header Thread32_1a,code32_idx
	cli
	hlt
	hlt


	USE32
Thread32_1a:
	mov ax,data16_idx
	mov ds,ax
	mov [FromThread5],1
;	qunlock16 mut_1
	cli
	hlt


USE32