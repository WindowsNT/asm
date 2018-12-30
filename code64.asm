; --------------------------------------- 64 bit Code ---------------------------------------
SEGMENT CODE64 USE64
ORG 0h


macro break64
{
	xchg bx,bx
}

include 'acpi64.asm'
include 'thread64.asm'
include 'vmxhost64.asm'

Start64:

	xor r8d,r8d
	linear rsp,stack64_end  
	push rax
	mov rax,0
	pop rax

	; access d64 using linear, ds not used
	xor rax,rax
	mov ax,DATA64
	shl rax,4
	add rax,d64
	mov byte [rax],1

; --------------------------------------- SIPI to real mode test ---------------------------------------
if TEST_LM_SIPI > 0 

	qlock64 mut_1

	linear rax,Thread16_4,CODE16
	mov rbx,1
	call SendSIPI64
	
	mov rax,mut_1
	call qwait64

end if

if TEST_VMX_1 > 0
; VMX operations

	call VMX_Host

end if 

	; Back to Compatibility Mode
	push code32_idx
	xor rcx,rcx
	mov ecx,Back32
	push rcx
	retf



