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

mov ax,0x4A00
mov bx,ENDS
int 0x21

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


; --------------------------------------- Prepare Long Mode  ---------------------------------------

if TEST_LONG > 0 

xor eax,eax
mov ax,CODE64
shl eax,4
add eax,Start64
push fs
mov bx,CODE32
mov fs,bx
mov dword [fs:PutLinearStart64],eax
pop fs
end if



; --------------------------------------- Protected Mode Find Page Entry  ---------------------------------------
xor ecx,ecx

if STATIC_PAGE32 = 0
; Alloc 32 Pages high, preserve low ram
mov edx,1024*100
call allochigh
mov [Paging32InXMSH],cx
mov [Paging32InXMS],edi
end if

LoopPMR:
xor eax,eax
if STATIC_PAGE32 = 1
	linear eax,Page32Null,PAGE32
else
	mov eax,[Paging32InXMS]
end if

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

if STATIC_PAGE64 = 0
; Alloc 64 Pages high, preserve low ram
mov edx,1024*100
call allochigh
mov [Paging64InXMSH],cx
mov [Paging64InXMS],edi
end if


xor ecx,ecx
LoopPMR2:
xor eax,eax
if STATIC_PAGE64 = 1
	linear eax,Page64Null,PAGE64
else
	mov eax,[Paging64InXMS]
end if 
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
if TEST_VMX_1 > 0 

if STATIC_PAGEVM = 0
; Alloc VMX Pages high, preserve low ram
mov edx,1024*100
call allochigh
mov [PagingVMInXMSH],cx
mov [PagingVMInXMS],edi
end if

xor ecx,ecx
LoopPMR5:
xor eax,eax

if STATIC_PAGEVM = 1
	linear eax,Ept64Null,VMXPAGE64
else
	mov eax,[PagingVMInXMS]
end if 
add eax,ecx
mov ebx,eax
shr eax,12
shl eax,12
cmp eax,ebx
jz LoopPRMFound5
inc ecx
jmp LoopPMR5
LoopPRMFound5:
mov [PhysicalEptOffset64],eax


end if

; --------------------------------------- Quick Unreal ---------------------------------------
push cs
cli
call EnterUnreal
sti

push cs
call InitPageTableFor64

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

if STATIC_PAGE32 = 0
; Free Paging 32 bit reserved in XMS
mov dx,[Paging32InXMSH]
call freehigh
end if

if STATIC_PAGE64 = 0
; Free Paging 64 bit reserved in XMS
mov dx,[Paging64InXMSH]
call freehigh
end if

if STATIC_PAGEVM = 0
; Free Paging VM bit reserved in XMS
mov dx,[PagingVMInXMSH]
call freehigh
end if

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
; Real mode test
mov ax,0900h
mov dx,rm1
int 21h

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


end if


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

