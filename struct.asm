; --------------------------------------- Macro and Structure Definitions ---------------------------------------

macro linear reg,trg,seg = DATA16
	{
;	xor reg,reg
	mov reg,seg
	shl reg,4
	add reg,trg
	}

macro dh_virtualization
{
		local .nuvmx
		local .nvmx

		; dh -> 0 no virtualization
		; dh -> 1 virtualization plain
		; dh -> 2 virtualization unrestricted guest
		mov eax,1
		cpuid
		xor dx,dx
		bt ecx,5
		jnc .nvmx
		mov dh,1
		xor eax,eax
		xor edx,edx
		mov ecx,0x48B ; IA32_VMX_PROCBASED_CTLS2
		rdmsr
		bt edx,7
		jnc .nuvmx
		mov dh,2
		jmp .nvmx
		.nuvmx:
		mov dh,1
		.nvmx:
}

macro pushadxeax
	{
	push ebx
	push ecx
	push edx
	push esi
	push edi
	push ebp
	}
	
macro popadxeax
	{
	pop ebp
	pop edi
	pop esi
	pop edx
	pop ecx
	pop ebx
	}

macro push64
	{
	push rax
	push rbx
	push rcx
	push rdx
	push rsi
	push rdi
	push rbp
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push r14
	push r15
	}
	
macro pop64
	{
	pop r15
	pop r14
	pop r13
	pop r12
	pop r11
	pop r10
	pop r9
	pop r8
	pop rbp
	pop rdi
	pop rsi
	pop rdx
	pop rcx
	pop rbx
	pop rax
	}

struc A_CPU a,b,c,d
        {
        .acpi   dd a
        .apic   dd b
        .flags  dd c
		.handle dd d
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
struc IDT_STR o0_15,se0_15,zb,flags,o16_31
        {
		.o0_15   dw o0_15
		.se0_15  dw se0_15
		.zb      db zb
		.flags   db flags
		.o16_31  dw o16_31
        }
struc IDT_STR64 o0_15,se0_15,zb,flags,o16_31,o32_63,zr
        {
		.o0_15   dw o0_15
		.se0_15  dw se0_15
		.zb      db zb
		.flags   db flags
		.o16_31  dw o16_31
		.o32_63  dd o32_63
		.zr      dd zr
        }

macro vmw16 code,value
{
	mov ebx,code
	xor eax,eax
	mov ax,value
	vmwrite ebx,eax
}

macro vmw32 code,value
{
	mov ebx,code
	mov eax,value
	vmwrite ebx,eax
}
macro vmw64 code,value
{
	mov rbx,code
	mov rax,value
	vmwrite rbx,rax
}

macro vmr r,code
{
	mov rbx,code
	vmread r,rbx
}

macro break
{
xchg bx,bx
}
