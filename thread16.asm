USE16

macro thread16header sts,sto
{
	db 4096 dup (144) ; // fill NOPs
	
	; Load IDT
	CLI
	mov di,DATA16
	mov ds,di
	lidt fword [ds:idt_RM_start]

	; Stack
	mov ax,sts
	mov ss,ax
	mov sp,sto
		
	; A20
	call FAR CODE16:EnableA20f

	; Quick Enter Unreal
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
}

Thread16_1:

	thread16header STACK16T1,stack16t1_end

    ; Start
	mov [FromThread1],1
	qunlock16 mut_1
	cli
	hlt
		

Thread16_2:

	thread16header STACK16T2,stack16t2_end

	mov [FromThread2],1
    sti 
	mov dx,thrm1
	mov ax,0900h
	int 21h
	cli

	qunlock16 mut_1
	cli
	hlt
		
Thread16_3:

	thread16header STACK16T2,stack16t3_end

	mov [FromThread3],1
    sti 
	mov dx,thrm2
	mov ax,0900h
	int 21h
	cli

	qunlock16 mut_1
	cli
	hlt
		
