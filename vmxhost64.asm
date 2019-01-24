USE64

; https://www.intel.com/content/www/us/en/architecture-and-technology/64-ia-32-architectures-software-developer-vol-2b-manual.html
; Full 2B manual
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

VMX_Initialize_VMX_Controls:
    ; edx = 0x82 for unrestricted guestm, 0x2 if simple with EPT

	vmw32 0x4012,0x11FF ; Entry. Ideally, we must read 0x484 MSR to learn what to put here
	; bit 9 - Guest is in long mode
	; bit 10 - Guest is in SMM
	; bit 11 - Deactivate Dual monitor treatment
	
	; We can use also 0x4014 to control MSRs -> if different than the host (mighty)

	vmw32 0x4000,0x1F ; PIN, Intel 3B Chapter 20.6.1
	; vmw32 0x4002,0x8401e9f2; Proc, Intel 3B Chapter 20.6.2
	vmw32 0x4002,0x840069F2; Proc, Intel 3B Chapter 20.6.2, Leave CR3 access so we can enable long mode

	vmw32 0x401E,edx
	vmw32 0x400C,0x36FFF
RET


VMX_Initialize_Host:
	; We initialize
	; CR0, CR3 , CR4
	; CS:RIP for entry after VMExit
	; SS:RSP for entry after VMExit
	; DS,ES,TR
	; GDTR,IDTR
	; RCX = IP

	; CRX

	vmw64 0x6C00,cr0
	vmw64 0x6C02,cr3
	vmw64 0x6C04,cr4

	; CS:RIP
	vmw16 0xC02,cs
	vmw64 0x6C16,rcx

	; SS:RSP
	vmw16 0xC04,ss
	vmw64 0x6C14,rsp

	; DS,ES,FS,GS,TR
	vmw16 0xC06,ds
	vmw16 0xC00,es
	vmw16 0xC08,fs
	vmw16 0xC0A,gs
	vmw16 0xC0C,tssd32_idx

	; GDTR, IDTR
	linear rdi,TempData,VMXDATA64
	sgdt [rdi] ; 10 bytes : 2 limit and 8 item
	mov rax,[rdi + 2]
	mov rbx,0x6C0C
	vmwrite rbx,rax

	linear rdi,TempData,VMXDATA64
	sidt [rdi] ; 10 bytes : 2 limit and 8 item
	mov rax,[rdi + 2]
	mov rbx,0x6C0E
	vmwrite rbx,rax

	; EFER
	mov ecx, 0c0000080h ; EFER MSR number. 
	rdmsr ; Read EFER.
	mov rbx,0x2C02
	vmwrite rbx,rax
RET

VMX_InitializeEPT:
	xor rdi,rdi
	linear rax,PhysicalEptOffset64,DATA16
	mov rdi,[rax]
 
	; Clear everything
	push rdi
	xor rax,rax
	mov ecx,8192
	rep stosq
	pop rdi
	; RSI to PDPT
	mov rsi,rdi
	add rsi,8*512

	; first pml4t entry
	xor rax,rax
	mov rax,rsi ; RAX now points to the RSI (First PDPT entry)
	shl rax,12 ; So we move it to bit 12
	shr rax,12 ; We remove the lower 4096 bits
	or rax,7 ; Add the RWE bits
	mov [rdi],rax ; Store the PML4T entry. We only need 1 entry

	
	; First PDPT entry (1st GB)
	xor rax,rax
	or rax,7 ; Add the RWE bits
	bts rax,7 ; Add the 7th "S" bit to tell the CPU that this doesn't refer to a PDT
	mov [rsi],rax ; Store the PMPT entry for 1st GB

	; Second PDPT entry (2nd GB)
	add rsi,8
	xor rax,rax
	mov rax,1024*1024*1024*1
	shr rax,12
	shl rax,12
	or rax,7 ; Add the RWE bits
	bts rax,7 ; Add the 7th "S" bit to tell the CPU that this doesn't refer to a PDT
	mov [rsi],rax ; Store the PMPT entry for 2nd GB

	; Third PDPT entry (3rd GB)
	add rsi,8
	xor rax,rax
	mov rax,1024*1024*1024*2
	shr rax,12
	shl rax,12
	or rax,7 ; Add the RWE bits
	bts rax,7 ; Add the 7th "S" bit to tell the CPU that this doesn't refer to a PDT
	mov [rsi],rax ; Store the PMPT entry for 3rd GB

	; Fourh PDPT entry (4th GB)
	add rsi,8
	xor rax,rax
	mov rax,1024*1024*1024*3
	shr rax,12
	shl rax,12
	or rax,7 ; Add the RWE bits
	bts rax,7 ; Add the 7th "S" bit to tell the CPU that this doesn't refer to a PDT
	mov [rsi],rax ; Store the PMPT entry for 4th GB


RET

; A Protected mode guest
VMX_Initialize_Guest2:

	; r8 -> selector
	; r9 -> base
	; r10 -> entry

    xor rax,rax
	; cr0,cr3,cr4 paging protected mode
	; cs ss:rip
	; flags

	; CRx

	mov ebx,0x6800 ; CR0
	mov eax,0x80000031 ; And the NX bit must be set
	bts eax,31 ; And Paging bit enabled
	vmwrite rbx,rax

	mov ebx,0x6802 ; CR3
	xor rax,rax
	linear rax,PhysicalPagingOffset32,DATA16
	mov eax,[rax]
	vmwrite rbx,rax

	mov ebx,0x6804 ; CR4
	mov eax,0
	bts eax,13 ; the 13th bit of CR4 must be set in VMX mode
	;bts eax,4 ; Page Size 4MB 
	vmwrite rbx,rax

	; Flags
	mov ebx,0x6820 ; RFLAGS
	mov rax,2
	vmwrite rbx,rax

	; Startup from r9 : r10

	; cs stuff
	xor rax,rax
	mov rax,r8
	mov ebx,0x802 ; CS selector
	vmwrite rbx,rax

	xor rax,rax
	mov rax,0xfffff
	mov ebx,0x4802 ; CS limit
	vmwrite rbx,rax

	mov rax,0c09fh
	mov ebx,0x4816 ; CS access
	vmwrite rbx,rax

	xor rax,rax
	mov rax,r9
	shl rax,4
	mov ebx,0x6808 ; CS base
	vmwrite rbx,rax

	; xchg bx,bx
	mov ebx,0x681E ; IP
	xor rax,rax
	add rax,r10
	vmwrite rbx,rax

	; GDTR,IDTR
	mov ebx,0x6816 ; GDTR Base
	;mov rax,gdt_ptr
	linear rax,gdt_ptr,DATA16
	add rax,4
	vmwrite rbx,rax
	mov ebx,0x4810 ; Limit
	mov rax,gdt_size
	vmwrite rbx,rax
	mov ebx,0x6818 ; IDTR Base
	mov rax,idt_PM_ptr
	vmwrite rbx,rax
	mov ebx,0x4812 ; Limit
	mov rax,idt_size
	vmwrite rbx,rax

	; DR7
	mov ebx,0x681A ; DR7
	mov rax,0x400
	vmwrite rbx,rax

	; SEGMENT registers

	; es,ss,ds,fs,gs
	vmw16 0x800,page32_idx
	vmw16 0x804,page32_idx
	vmw16 0x806,page32_idx
	vmw16 0x808,page32_idx
	vmw16 0x80A,page32_idx

	; Limits
	vmw32 0x4800,0xFFFFF
	vmw32 0x4804,0xFFFFF
	vmw32 0x4806,0xFFFFF
	vmw32 0x4808,0xFFFFF
	vmw32 0x480A,0xFFFFF

	; Access
	vmw16 0x4814,0x0C093
	vmw16 0x4818,0x0C093
	vmw16 0x481A,0x0C093
	vmw16 0x481C,0x0C093
	vmw16 0x481E,0x0C093

	; base
	vmw32 0x6806,0
	vmw32 0x680A,0
	vmw32 0x680C,0
	vmw32 0x680E,0
	vmw32 0x6810,0


	; LDT (Dummy)
	xor rax,rax
	mov ax,ldt_idx
	mov ebx,0x80C ; LDT selector
	vmwrite rbx,rax
	mov rax,0xffffffff
	mov ebx,0x480C ; LDT limit
	vmwrite rbx,rax
	mov rax,0x10000
	mov ebx,0x4820 ; LDT access
	vmwrite rbx,rax
	mov rax,0
	mov ebx,0x6812 ; LDT base
	vmwrite rbx,rax

	; TR (Dummy)
	xor rax,rax
	mov ax,tssd32_idx
	mov ebx,0x80E ; TR selector
	vmwrite rbx,rax
	mov rax,0xff
	mov ebx,0x480E ; TR limit
	vmwrite rbx,rax
	mov rax,0x8b
	mov ebx,0x4822 ; TR access
	vmwrite rbx,rax
	mov rax,0
	mov ebx,0x6814 ; TR base
	vmwrite rbx,rax

RET

; A real mode guest
VMX_Initialize_UnrestrictedGuest:

	; cr0,cr3,cr4 real mode
	; cs ss:rip
	; flags

	xor rax,rax

	; CRx
	mov ebx,0x6800 ; CR0
	mov eax,0x60000030 ; And the NX bit must be set
	vmwrite rbx,rax
	mov ebx,0x6802 ; CR3
	mov eax,0
	vmwrite rbx,rax
	mov ebx,0x6804 ; CR4
	mov eax,0
	bts eax,13 ; the 13th bit of CR4 must be set in VMX mode
	vmwrite rbx,rax

	; Flags
	mov ebx,0x6820 ; RFLAGS
	mov rax,2
	vmwrite rbx,rax

	; Startup from VMX16 : StartVM


	; cs stuff
	xor rax,rax
	mov ax,code32_idx
	mov ebx,0x802 ; CS selector
	vmwrite rbx,rax

	xor rax,rax
	mov rax,0xffff
	mov ebx,0x4802 ; CS limit
	vmwrite rbx,rax

	mov rax,09fh
	mov ebx,0x4816 ; CS access
	vmwrite rbx,rax

	xor rax,rax
	mov rax,r9
	shl rax,4
	mov ebx,0x6808 ; CS base
	vmwrite rbx,rax


	mov ebx,0x681E ; IP
	xor rax,rax
	mov rax,r10
	vmwrite rbx,rax

	; GDTR,IDTR
	mov ebx,0x6816 ; GDTR Base
	mov rax,0
	vmwrite rbx,rax
	mov ebx,0x4810 ; Limit
	mov rax,0xFFFF
	vmwrite rbx,rax
	mov ebx,0x6818 ; IDTR Base
	mov rax,0
	vmwrite rbx,rax
	mov ebx,0x4812 ; Limit
	mov rax,0xFFFF
	vmwrite rbx,rax

	; DR7
	mov ebx,0x681A ; DR7
	mov rax,0x400
	vmwrite rbx,rax

	; SEGMENT registers


	; es,ss,ds,fs,gs
	vmw16 0x800,data32_idx
	vmw16 0x804,data32_idx
	vmw16 0x806,data32_idx
	vmw16 0x808,data32_idx
	vmw16 0x80A,data32_idx

	; Limits
	vmw32 0x4800,0xFFFF
	vmw32 0x4804,0xFFFF
	vmw32 0x4806,0xFFFF
	vmw32 0x4808,0xFFFF
	vmw32 0x480A,0xFFFF

	; Access
	vmw16 0x4814,0x93
	vmw16 0x4818,0x93
	vmw16 0x481A,0x93
	vmw16 0x481C,0x93
	vmw16 0x481E,0x93

	; base
	mov rax,r9
	shl rax,4
	vmw64 0x6806,rax
	vmw64 0x680A,rax
	vmw64 0x680C,rax
	vmw64 0x680E,rax
	vmw64 0x6810,rax


	; LDT (Dummy)
	xor rax,rax
	mov ax,ldt_idx
	mov ebx,0x80C ; LDT selector
	vmwrite rbx,rax
	mov rax,0xffffffff
	mov ebx,0x480C ; LDT limit
	vmwrite rbx,rax
	mov rax,0x10000
	mov ebx,0x4820 ; LDT access
	vmwrite rbx,rax
	mov rax,0
	mov ebx,0x6812 ; LDT base
	vmwrite rbx,rax

	; TR (Dummy)
	xor rax,rax
	mov ax,tssd32_idx
	mov ebx,0x80E ; TR selector
	vmwrite rbx,rax
	mov rax,0xff
	mov ebx,0x480E ; TR limit
	vmwrite rbx,rax
	mov rax,0x8b
	mov ebx,0x4822 ; TR access
	vmwrite rbx,rax
	mov rax,0
	mov ebx,0x6814 ; TR base
	vmwrite rbx,rax

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
	wrmsr
	.VMX_LB_Enabled:

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

; ---------------- VMX Host Exit ----------------
VMX_VMExit:
	nop
	; Disable
	call VMX_Disable
RET


VMXInit:
	
	; Load the revision
	linear rdi,VMXRevision,VMXDATA64
	mov ebx,[rdi];

	; Initialize the region
	linear rdi,VMXStructureData2,VMXDATA64
	mov rcx,[rdi];  Get address of data1
	mov rsi,rdi
	mov rdi,rcx
	mov [rdi],ebx ; // Put the revision
	VMCLEAR [rsi]
	mov [rdi],ebx ; // Put the revision
	VMPTRLD [rsi] 
	mov [rdi],ebx ; // Put the revision

RET


VMXInit2:

	; The EPT initialization for the guest
	linear rax,PhysicalEptOffset64,DATA16
	mov rax,[rax]
	or rax,0 ; Memory Type 0
	or rax,0x18 ; Page Walk Length 3
	mov rbx,0x201A ; EPTP
	vmwrite rbx,rax
 
	; The Link Pointer -1 initialization
	mov rax,0xFFFFFFFFFFFFFFFF
	mov rbx,0x2800 ; LP
	vmwrite rbx,rax
 
	; One more RSP initialization of the host
	xor rax,rax
	mov rbx,0x6c14 ; RSP
	mov rax,rsp
	add rax,8 ; because we are in a function call
	vmwrite rbx,rax

RET

; ---------------- Host Start ----------------
VMX_Host:
	linear rbx,vmt1,DATA16
	mov byte [rbx],0
	call VMX_ExistenceTest
	cmp rax,1
	jz .yvmx
RET
.yvmx:
	linear rbx,vmt1,DATA16
	mov byte [rbx],1

	; Init structures
	call VMX_Init

	; Enable
	call VMX_Enable


if TEST_VMX = 1

    ; Real mode guest (unrestricted)

	call VMXInit
  
	call VMX_InitializeEPT
	xor rdx,rdx
	bts rdx,1
	bts rdx,7
	call VMX_Initialize_VMX_Controls
	linear rcx,VMX_VMExit,CODE64
	call VMX_Initialize_Host
	mov r9,VMX16
	mov r10,StartVM
	call VMX_Initialize_UnrestrictedGuest
 
 
	call VMXInit2


	; Launch it!!
	VMLAUNCH

end if

if TEST_VMX = 2

    ; Protected mode guest 

	call VMXInit
 
	; Initializzation
	mov rdx,0x49
	call VMX_Initialize_VMX_Controls
	linear rcx,VMX_VMExit,CODE64
	call VMX_Initialize_Host
	mov r8,vmx32_idx
	mov r9,VMX32
	mov r10,StartVM2
	call VMX_Initialize_Guest2
 
	call VMXInit2

	; Launch it!!
	VMLAUNCH

end if 


	; If we get here, VMLAUNCH failed

	; Disable
	call VMX_Disable

RET
