FORMAT MZ
HEAP 0

macro linear reg,trg,seg = DATA16
	{
	mov reg,seg
	shl reg,4
	add reg,trg
	}
struc GDT_STR s0_15,b0_15,b16_23,flags,access,b24_31
        {
		.s0_15   dw s0_15
		.b0_15   dw b0_15
		.b16_23  db b16_23
		.flags   db flags
		.access  db access
		.b24_31  db b24_31
        }



segment DATA16
USE16

; And For Quick Unreal
gdt_startUNR dw gdt_sizeUNR
gdt_ptrUNR dd 0
dummy_descriptorUNR GDT_STR 0,0,0,0,0,0
code16_descriptorUNR  GDT_STR 0ffffh,0,0,9ah,0,0
data32_descriptorUNR  GDT_STR 0ffffh,0,0,92h,0cfh,0
gdt_sizeUNR = $-(dummy_descriptorUNR)




; main
segment CODE16
USE16

m1 db "Hello",0xD,0xA,"$"

include 'unreal.asm'

start16:
    mov ax,CODE16
	mov ds,ax
	mov ax,0x0900
	mov dx,m1
	int 0x21
	nop
	nop

	; Enter Unreal
	;call EnterUnreal
	
	mov ax,0x4C00
	int 0x21

SEGMENT ENDS 
entry CODE16:start16


