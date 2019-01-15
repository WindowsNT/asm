SEGMENT DATA16 USE16



; --------------------------------------- 16 bit data ---------------------------------------
a20enabled db 0
numcpus db 0
somecpu A_CPU 0,0,0,0
cpusstructize = $-(somecpu)
CpusOfs:
cpus db cpusstructize*64 dup(0)
MainCPUAPIC db 0
LocalApic dd 0xFEE00000
RsdtAddress dd 0
XsdtAddress dq 0
ProcedureStart dd 0
FromThread1 db 0 
FromThread2 db 0 
FromThread3 db 0 
FromThread4 db 0 
FromThread5 db 0 
FromThread6 db 0 
of0s dw 0
of0o dw 0

LongModeSupported db 0
Support1GBPaging db 0 
VMXSupported db 0 

if STATIC_PAGE32 = 0
Paging32InXMS dd 0
Paging32InXMSH dw 0
end if

if STATIC_PAGE64 = 0
Paging64InXMS dd 0
Paging64InXMSH dw 0
end if

if STATIC_PAGEVM = 0
PagingVMInXMS dd 0
PagingVMInXMSH dw 0
end if

; --------------------------------------- VMX tests---------------------------------------
vmt1 db 0 ; existence
vmt2 db 0 ; protected mode guest

vmm1 db "VMX Exists, OK",0dh,0ah,"$"
vmm2 db "VMX Launch VM in Protected Mode, OK",0dh,0ah,"$"

; --------------------------------------- 16 bit mutexes ---------------------------------------
mut_ipi db 0xFF
mut_1 db 0xFF
mut_i21 db 0xFF

; --------------------------------------- Messages ---------------------------------------
rm1 db "Real mode test, OK",0dh,0ah,"$"
pm1 db "Protected mode test, OK",0dh,0ah,"$"
lm1 db "Long mode test, OK",0dh,0ah,"$"
ap1 db "Apic 1 found",0dh,0ah,"$"
ap2 db "Apic 2 found",0dh,0ah,"$"

cpuf db "CPU $"
thrm1 db "Message from real mode thread",0dh,0ah,"$"
thrm2 db "Message from real mode thread called from protected mode",0dh,0ah,"$"
thrm3 db "Message from real mode thread called from long mode",0dh,0ah,"$"
thr1 db "Thread 1 executed, OK",0dh,0ah,"$"
thr2 db "Thread 2 executed, OK",0dh,0ah,"$"
thr3 db "Thread 3 real mode executed from protected mode, OK",0dh,0ah,"$"
thr4 db "Thread 4 real mode executed from long mode, OK",0dh,0ah,"$"
thr5 db "Thread 5 protected mode executed from real mode, OK",0dh,0ah,"$"
thr6 db "Thread 6 long mode executed from real mode, OK",0dh,0ah,"$"

resm db "DMMI Server Active",0dh,0ah,"$"
resm2 db "DMMI Server Already installed",0dh,0ah,"$"

a20off db "Restoring A20",0dh,0ah,"$"

crlf db 0dh,0ah,"$"


; --------------------------------------- GDT ---------------------------------------
gdt_start dw gdt_size
gdt_ptr dd 0
dummy_descriptor   GDT_STR 0,0,0,0,0,0
code32_descriptor  GDT_STR 0ffffh,0,0,9ah,0cfh,0 ; 4GB 32-bit code , 9ah = 10011010b = Present, DPL 00,No System, Code Exec/Read. 0cfh access = 11001111b = Big,32bit,<resvd 0>,1111 more size
data32_descriptor  GDT_STR 0ffffh,0,0,92h,0cfh,0 ; 4GB 32-bit data,   92h = 10010010b = Presetn , DPL 00, No System, Data Read/Write
stack32_descriptor GDT_STR 0ffffh,0,0,92h,0cfh,0 ; 4GB 32-bit stack
code16_descriptor  GDT_STR 0ffffh,0,0,9ah,0,0    ; 64k 16-bit code
data16_descriptor  GDT_STR 0ffffh,0,0,92h,0,0    ; 64k 16-bit data
stack16_descriptor GDT_STR 0ffffh,0,0,92h,0,0    ; 64k 16-bit data
ldt_descriptor     GDT_STR ldt_size,0,0,82h,0,0  ; pointer to LDT,  82h = 10000010b = Present, DPL 00, System , Type "0010b" = LDT entry
code64_descriptor  GDT_STR 0ffffh,0,0,9ah,0afh,0 ; 16TB 64-bit code, 08cfh access = 01001111b = Big,64bit (0), 1111 more size
page32_descriptor  GDT_STR 0ffffh,0,0,92h,0cfh,0 ; 4GB 32-bit data,   92h = 10010010b = Presetn , DPL 00, No System, Data Read/Write
page64_descriptor  GDT_STR 0ffffh,0,0,92h,0cfh,0 ; 4GB 32-bit data,   92h = 10010010b = Presetn , DPL 00, No System, Data Read/Write
absd32_descriptor  GDT_STR 0ffffh,0,0,92h,0cfh,0 ; 4GB 32-bit data,   92h = 10010010b = Presetn , DPL 00, No System, Data Read/Write
data64_descriptor  GDT_STR 0ffffh,0,0,92h,0afh,0 ; 16TB 64-bit data, 08cfh access = 10001111b = Big,64bit (0), 1111 more size
absd64_descriptor  GDT_STR 0ffffh,0,0,92h,0afh,0 ; 16TB 64-bit data, 08cfh access = 10001111b = Big,64bit (0), 1111 more size
tssd32_descriptor  GDT_STR 0h,0,0,89h,040h,0 ; TSS segment in GDT
vmx32_descriptor   GDT_STR 0ffffh,0,0,9ah,0cfh,0 ; 4GB 32-bit code , 9ah = 10011010b = Present, DPL 00,No System, Code Exec/Read. 0cfh access = 11001111b = Big,32bit,<resvd 0>,1111 more size
raw32_descriptor   GDT_STR 0ffffh,0,0,9ah,0cfh,0 ; 4GB 32-bit code , 9ah = 10011010b = Present, DPL 00,No System, Code Exec/Read. 0cfh access = 11001111b = Big,32bit,<resvd 0>,1111 more size
tssd64_descriptor  GDT_STR 0h,0,0,89h,040h,0 ; TSS segment in GDT
gdt_size = $-(dummy_descriptor)

dummy_idx       = 0h    ; dummy selector
code32_idx      =       08h             ; offset of 32-bit code  segment in GDT
data32_idx      =       10h             ; offset of 32-bit data  segment in GDT
stack32_idx     =       18h             ; offset of 32-bit stack segment in GDT
code16_idx      =       20h             ; offset of 16-bit code segment in GDT
data16_idx      =       28h             ; offset of 16-bit data segment in GDT
stack16_idx     =       30h             ; offset of 16-bit stack segment in GDT
ldt_idx         =       38h             ; offset of LDT in GDT
code64_idx      =       40h             ; offset of 64-bit code segment in GDT
page32_idx      =       48h             ; offset of 32-bit data segment in GDT
page64_idx      =       50h             ; offset of 64-bit data segment in GDT
absd32_idx      =       58h             ; offset of 32-bit data  segment in GDT
data64_idx      =       60h             ; offset of 64-bit data segment in GDT
absd64_idx      =       68h             ; offset of 64-bit data segment in GDT
tssd32_idx      =       70h             ; TSS descriptor
vmx32_idx       =       78h             ; offset of 32-bit code  segment in GDT
raw32_idx       =       80h             ; offset of 32-bit code  segment in GDT
tssd64_idx      =       88h             ; TSS descriptor

data32_ldt_idx  =       04h             ; offset of 32-bit data  segment in LDT


; And For Quick Unreal
gdt_startUNR dw gdt_sizeUNR
gdt_ptrUNR dd 0
dummy_descriptorUNR GDT_STR 0,0,0,0,0,0
code16_descriptorUNR  GDT_STR 0ffffh,0,0,9ah,0,0
data32_descriptorUNR  GDT_STR 0ffffh,0,0,92h,0cfh,0
gdt_sizeUNR = $-(dummy_descriptorUNR)


; --------------------------------------- IDT ---------------------------------------

idt_RM_start      dw 0
idt_RM_ptr dd 0

idt_PM_start      dw             idt_size
idt_PM_ptr dd 0
interruptsall rb 256*8
;interruptsall IDT_STR 0,0,0,0,0
; rb 256 * 8
idt_size=$-(interruptsall)


idt_LM_start      dw             idtl_size
idt_LM_ptr db 0 dup(8)
interruptsall64 rb 256*16
idtl_size=$-(interruptsall64)



; --------------------------------------- PAGE ---------------------------------------
PhysicalPagingOffset32 dd 0
PhysicalPagingOffset64 dd 0
PhysicalEptOffset64 dd 0

; --------------------------------------- Supported ---------------------------------------
supportlm db "Long Mode Supported",0x0d,0x0a,"$"
support1gb db "1GB Paging Supported",0x0d,0x0a,"$"
supportvm db "VM Supported",0x0d,0x0a,"$"

