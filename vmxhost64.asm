USE64


; ---------------- Existance test ----------------
VMX_ExistenceTest: ; RAX 1 if VMX is supported
	MOV RAX,1
	CPUID
	XOR EAX,EAX
	BTC ECX,5
	JNC .f
	MOV EAX,1
	.f:
RET

; ---------------- A20 routines in 64 bit ----------------
VMX_EnableA20:
	push ax
	in al,92h
	or al,02
	out 92h,al
	pop ax
ret
VMX_DisableA20:
	push ax
	in al,92h
	and al,0fdh
	out 92h,al
	pop ax
ret

; ---------------- Init the structures ----------------
VMX_Init:

	 ; Read MSR
	 xor eax,eax
	 mov ecx,0480h
	 rdmsr

	 linear ecx,VMXRevision,VMXDATA64
	 ; EAX holds the revision
	 ; EDX lower 13 bits hold the max size
	 mov [ecx],eax
	 and edx,8191
	 linear ecx,VMXStructureSize,VMXDATA64
	 mov [ecx],edx
	 ; Initialize 4096 structure datas for VMX
	 xor eax,eax
	 mov ax,VMXDATA64
	 shl eax,4 ; physical
	 Loop5X:
	 test eax,01fffh
	 jz Loop5End
	 inc eax
	 jmp Loop5X
	 Loop5End:
	 linear ecx,VMXStructureData1,VMXDATA64
	 mov dword [ecx],eax
	 add eax,4096
	 linear ecx,VMXStructureData2,VMXDATA64
	 mov dword [ecx],eax
	 add eax,4096
	 linear ecx,VMXStructureData3,VMXDATA64
	 mov dword [ecx],eax

 RET






; ---------------- Enable VMX ----------------
VMX_Enable:


	; A20
	; call VMX_DisableA20

	; cr4
	mov rax,cr4
	bts rax,13
	mov cr4,rax

    ; Load the revision
	linear rdi,VMXRevision,VMXDATA64
	mov ebx,[edi];
	
	; Initialize the VMXON region
	linear rdi,VMXStructureData1,VMXDATA64
	mov rcx,[rdi];  Get address of data1
	mov rsi,rdi
	mov rdi,rcx

	; CR0 bit 5
	mov rax,cr0
	bts rax,5
	mov cr0,rax
 
	; MSR 0x3ah lock bit 0
	mov ecx,03ah
	rdmsr
	test eax,1
	jnz .VMX_LB_Enabled
	or eax,1
	.VMX_LB_Enabled:
	wrmsr

	; Execute the VMXON
	mov [rdi],ebx ; // Put the revision
	mov rax,[rsi]
	VMXON [rsi]

RET

; ---------------- Disable VMX ----------------
VMX_Disable:
	VMXOFF

	; A20
	;call VMX_EnableA20

	mov rax,cr4
	btc rax,13
	mov cr4,rax
RET
; ---------------- Host Start ----------------
VMX_Host:
	linear rbx,vmt1
	mov byte [rbx],0
	call VMX_ExistenceTest
	cmp rax,1
	jz .yvmx
RET
.yvmx:
	linear rbx,vmt1
	mov byte [rbx],1

	; Init structures
	call VMX_Init

	; Enable
	call VMX_Enable

	; Disable
	call VMX_Disable



RET
