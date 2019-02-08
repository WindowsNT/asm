SEGMENT CODE16 USE16
ORG 0h

macro break16
{
	xchg bx,bx
}

INCLUDE 'himem16.asm'
INCLUDE 'unreal.asm'
INCLUDE 'page16.asm'
INCLUDE 'acpi16.asm'
INCLUDE 'thread16.asm'
INCLUDE 'opcodes.asm'


macro EnterProtected ofs32 = Start32,codeseg = code32_idx,noinits = 0
{
    mov ax,noinits
	cmp ax,1
	jz .noinitg
	mov ax,DATA16
	mov ds,ax
	call far CODE16:GDTInit
	call far CODE16:IDTInit
	call far CODE16:IDTInit64
	.noinitg:
	cli
	mov bx,gdt_start
	lgdt [bx]
	mov bx,idt_PM_start

	; = NO DEBUG HERE =
	lidt [bx]
	mov eax,cr0
	or al,1
	mov cr0,eax 

	; gs load with linear data so DMMI knows
	mov ax,page32_idx
	mov gs,ax

	db  066h  
	db  0eah 
	dd  ofs32
	dw  codeseg

	NOP ; never executed
}


INCLUDE 'int16.asm'

; --------------------------------------- This is where the application starts ---------------------------------------
start16:

; --------------------------------------- Initialization of our segments ---------------------------------------
cli

; Overriden by HEAP 0 in entry.asm
;mov ax,0x4A00
;mov bx,ENDS
;int 0x21



mov ax,DATA16
mov ds,ax
mov es,ax
mov ax,STACK16
mov sp,stack16_end
mov ss,ax
sti
mov bx,idt_RM_start
sidt [bx] 

; --------------------------------------- HIMEM.SYS test ---------------------------------------

call himemthere
mov edx,1024
call allochigh
mov dx,cx
call freehigh

; --------------------------------------- A20 line  ---------------------------------------

mov [ds:a20enabled],0
call CheckA20
jc A20AlreadyOn
call EnableA20
mov [ds:a20enabled],1
A20AlreadyOn:

; --------------------------------------- Opcode tests ---------------------------------------
call OpcodeTest


; --------------------------------------- Prepare Long Mode  ---------------------------------------

if TEST_LONG > 0 

; Supported?
mov [LongModeSupported],0
mov eax, 0x80000000 
cpuid
cmp eax, 0x80000001
jb .NoLongMode         
mov [LongModeSupported],1
mov dx,supportlm
mov ax,0x0900
int 0x21

xor eax,eax
mov ax,CODE64
shl eax,4
add eax,Start64
push fs
mov bx,CODE32
mov fs,bx
mov dword [fs:PutLinearStart64],eax
pop fs

; And Page 1GB Support
mov [Support1GBPaging],0
mov eax,80000001h
cpuid
bt edx,26
jnc .no1gbpg
mov [Support1GBPaging],1
mov dx,support1gb
mov ax,0x0900
int 0x21
.no1gbpg:
.NoLongMode:

end if




; --------------------------------------- Protected Mode Find Page Entry  ---------------------------------------
xor ecx,ecx

; Alloc 32 Pages high, preserve low ram
mov edx,1024*100
call allochigh
mov [Paging32InXMSH],cx
mov [Paging32InXMS],edi

LoopPMR:
xor eax,eax
mov eax,[Paging32InXMS]

add eax,ecx
mov ebx,eax
shr eax,12
shl eax,12
cmp eax,ebx
jz LoopPRMFound
inc ecx
jmp LoopPMR
LoopPRMFound:
mov [PhysicalPagingOffset32],eax


; --------------------------------------- Long Mode Find Page Entry  ---------------------------------------
if TEST_LONG > 0 

; Alloc 64 Pages high, preserve low ram
mov edx,1024*100
call allochigh
mov [Paging64InXMSH],cx
mov [Paging64InXMS],edi


xor ecx,ecx
LoopPMR2:
xor eax,eax
mov eax,[Paging64InXMS]
add eax,ecx
mov ebx,eax
shr eax,12
shl eax,12
cmp eax,ebx
jz LoopPRMFound2
inc ecx
jmp LoopPMR2
LoopPRMFound2:
mov [PhysicalPagingOffset64],eax


end if

; --------------------------------------- VMX EPT Find Page Entry  ---------------------------------------
if TEST_VMX > 0 


mov [VMXSupported],0
mov [VMXUnrestrictedSupported],0
mov eax,1
cpuid
bt ecx,5
jnc VMX_NotSupported 
mov [VMXSupported],1
mov dx,supportvm
mov ax,0x0900
int 0x21

; Unrestricted guest also
xor eax,eax
xor edx,edx
mov ecx,0x48B ; IA32_VMX_PROCBASED_CTLS2
rdmsr
bt edx,7
jnc VMX_NoUR

mov [VMXUnrestrictedSupported],1

VMX_NoUR:
VMX_NotSupported:

; Alloc VMX Pages high, preserve low ram
mov edx,1024*100
call allochigh
mov [PagingVMInXMSH],cx
mov [PagingVMInXMS],edi

xor ecx,ecx
LoopPMR5:
xor eax,eax

mov eax,[PagingVMInXMS]
add eax,ecx
mov ebx,eax
shr eax,12
shl eax,12
cmp eax,ebx
jz LoopPRMFound5
inc ecx
jmp LoopPMR5
LoopPRMFound5:
mov dword [PhysicalEptOffset64],eax


end if

; --------------------------------------- Quick Unreal ---------------------------------------



push cs
cli
call EnterUnreal
sti

push cs
call InitPageTableFor64

mov ax,CODE16
mov ds,ax
linear eax,Thread64P,CODE16
mov [Thread64Ptr1],eax
mov ax,CODE64
mov ds,ax
linear eax,Thread64_1a,CODE64
mov [Thread64Ptr2],eax
mov ax,CODE16
mov ds,ax
linear eax,BackFromExecutingInterruptLM,CODE64
mov [Thread64Ptr3],eax
mov ax,CODE16
mov ds,ax
linear eax,Thread64PV,CODE16
mov [Thread64Ptr4],eax
mov ax,CODE16
mov ds,ax
linear eax,UR_Mode_2,CODE16
mov [Thread64Ptr1V],eax

mov ax,CODE16
mov ds,ax
linear eax,VMX_Init_Structures,CODE64
mov [cv64_vmxinitstructures],eax
linear eax,VMX_Enable,CODE64
mov [cv64_vmxenable],eax
linear eax,VMX_Disable,CODE64
mov [cv64_vmxdisable],eax
linear eax,VMX_Initialize_Host,CODE64
mov [cv64_vmxinithost],eax
linear eax,VMX_Initialize_Guest2,CODE64
mov [cv64_vmxinitguest2],eax
linear eax,VMX_Initialize_UnrestrictedGuest,CODE64
mov [cv64_vmxinitguest1],eax
linear eax,VMX_InitializeEPT,CODE64
mov [cv64_vmxinitept],eax
linear eax,VMX_Initialize_VMX_Controls,CODE64
mov [cv64_vmxinitcontrols1],eax
mov [cv64_vmxinitcontrols2],eax


; --------------------------------------- Find ACPI  ---------------------------------------
if TEST_MULTI > 0 

mov ax,DATA16
mov ds,ax
push cs
call GetMyApic16f
mov [ds:MainCPUAPIC],bl

push cs

call FillACPI
cmp eax,0xFFFFFFFF
jnz .coo
jmp .noacpi
.coo:

cmp eax, 'XSDT'
jz .ac2

mov eax,'APIC'
push cs
mov ecx,4
mov edi,[RsdtAddress]
call FindACPITableX
jmp .eac

.ac2:
mov eax,'APIC'
push cs
mov ecx,8
mov edi,dword [XsdtAddress]
call FindACPITableX

.eac:
cmp eax,0xFFFFFFFF
jnz .coo2
jmp .noacpi
.coo2:
push cs
call DumpMadt
.noacpi:

end if


; Resident test /r cmdline
mov ax,0x6200
int 0x21
push ds
mov ds,bx
mov al,[0x80]
cmp al,3
jnz .nores

mov al,[0x82]
cmp al,'/'
jnz .nores
mov al,[0x83]
cmp al,'r'
jnz .nores

; Resident
    pop ds

if RESIDENT = 0
	mov ax,0x4c00
	int 0x21
end if

	; Check if there first
	mov ax,0x35F0
	int 0x21
	cmp dword [es:bx + 2],'dmmi'
	jz .yres
	jmp .fres

	.yres:
	mov ax,0
	int 0xF0
	cmp ax,0xFACE
	jnz .fres

	mov ax,DATA16
	mov ds,ax
    mov ax,0x0900
	mov dx,resm2
	int 0x21
	
	mov ax,0x4C00
	int 0x21
	


	.fres:
    mov ax,0x35F0
	int 0x21
	mov ax,DATA16
	mov ds,ax
	mov [of0s],es
	mov [of0o],bx

	mov ax,CODE16
	mov ds,ax
    mov ax,0x25F0
	mov dx,int16
	int 0x21

	mov ax,DATA16
	mov ds,ax
    mov ax,0x0900
	mov dx,resm
	int 0x21
	
	mov dx,ENDS
	mov ax,0x3100
	int 0x21



.nores:
pop ds



; --------------------------------------- Protected Mode Test ---------------------------------------

EnterProtected
 
; --------------------------------------- Exit ---------------------------------------

exit16:
mov     eax,cr0         
and     al,not 1        
mov     cr0,eax         
db      0eah
dw      flush_ipq,CODE16
flush_ipq:
mov     ax,STACK16 
mov     ss,ax
mov     sp,stack16_end
mov ax, DATA16
mov     ds,ax
mov     es,ax
mov     di,idt_RM_start
lidt    [di]
sti
; = END NO DEBUG HERE =

; Free Paging 32 bit reserved in XMS
mov dx,[Paging32InXMSH]
call freehigh

; Free Paging 64 bit reserved in XMS
mov dx,[Paging64InXMSH]
call freehigh

; Free Paging VM bit reserved in XMS
mov dx,[PagingVMInXMSH]
call freehigh

; --------------------------------------- Quick Unreal ---------------------------------------
push cs
cli
call EnterUnreal
sti

if TEST_LONG > 0 
; Restore screen (long mode bug) -- Fixed :)
;mov ax,3
;int 10h
end if




; --------------------------------------- ACPI tests ---------------------------------------
if TEST_MULTI > 0 
if TEST_RM_SIPI > 0 


qlock16 mut_1
qlock16 mut_1
qlock16 mut_1
qlock16 mut_1

xor eax,eax
mov ax,DATA16
mov ds,ax
linear eax,Thread16_1,CODE16
mov ebx,1
call far CODE16:SendSIPIf

xor eax,eax
mov ax,DATA16
mov ds,ax
linear eax,Thread16_2,CODE16
mov ebx,2
call far CODE16:SendSIPIf

xor eax,eax
mov ax,DATA16
mov ds,ax
linear eax,Thread32_1,CODE32
mov ebx,3
call far CODE16:SendSIPIf

xor eax,eax
mov ax,DATA16
mov ds,ax
linear eax,Thread64_1,CODE64
mov ebx,1 ; Back to 1 core
call far CODE16:SendSIPIf


mov ax,mut_1
push cs
call qwait16
mov ax,mut_1
push cs
call qwait16
mov ax,mut_1
push cs
call qwait16
mov ax,mut_1
push cs
call qwait16

end if
end if



; --------------------------------------- Tests ---------------------------------------



if TEST_MULTI > 0 

; NumCpus
xor cx,cx
mov cl,[ds:numcpus]
.cpul:
cmp cx,0
je .endr
dec cx
mov ax,0900h
mov dx,cpuf
int 21h
jmp .cpul
.endr:
mov ax,0900h
mov dx,crlf
int 21h


end if

push cs
call EnterUnreal

if TEST_MULTI > 0 

; Apic test
cmp dword [ds:RsdtAddress],0
jz .noa1
mov ax,0900h
mov dx,ap1
int 21h
mov edi, [ds:RsdtAddress]
push cs
mov ecx,4
call DumpAll
mov ax,0900h
mov dx,crlf
int 21h
.noa1:

cmp dword [ds:XsdtAddress],0
jz .noa2
mov ax,0900h
mov dx,ap2
int 21h
mov edi, dword [ds:XsdtAddress]
mov ecx,8
push cs 
call DumpAll
mov ax,0900h
mov dx,crlf
int 21h
.noa2:


macro thrtest too,msg
{
    local .fx
	mov ax,DATA16
	mov gs,ax
	cmp [gs:too],1
	jnz .fx
	mov dx,msg
	mov ax,0900h
	int 21h
	.fx:
}

thrtest FromThread1,thr1
thrtest FromThread2,thr2
thrtest FromThread3,thr3
thrtest FromThread4,thr4
thrtest FromThread5,thr5
thrtest FromThread6,thr6
mov ax,0x900
mov dx,crlf
int 0x21

end if

; Real mode test
mov ax,0900h
mov dx,rm1
int 21h

; PM mode test

mov ax,DATA32
mov gs,ax
cmp [gs:d32],1
jnz fail_1
mov dx,pm1
mov ax,0900h
int 21h
fail_1:

if TEST_LONG > 0 

; Long mode test
mov ax,DATA64
mov gs,ax
cmp [gs:d64],1
jnz fail_2
mov dx,lm1
mov ax,0900h
int 21h
fail_2:

end if

; VMX test
macro vmxshow vmt,vmm
{
    local .ffx
	cmp [vmt],1
	jnz .ffx
	mov dx,vmm
	mov ax,0900h
	int 21h
	.ffx:
}
vmxshow vmt1,vmm1
vmxshow vmt2,vmm2
vmxshow vmt3,vmm2


mov ax,0900h
mov dx,crlf
int 21h

; A20 off if enabled

cmp [ds:a20enabled],1
jnz SkipA20Disable

mov ax,0900h
mov dx,a20off
int 21h

call DisableA20
SkipA20Disable:

; --------------------------------------- Bye! ---------------------------------------
mov ax,4c00h
int 21h

