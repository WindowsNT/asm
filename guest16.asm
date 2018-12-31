SEGMENT VMX16 USE16



; VMX Entry for our Virtual Machine
; This is a Real Mode segment

; Note that since the memory is see through, BIOS and DOS interrupts work here!

StartVM:

; Remember we used a protected mode selector to get here?
; Jump to a real mode segment now so CS gets a proper value

; xchg bx,bx
nop
nop

db 0eah
dw PM_VM_Entry,VMX16
PM_VM_Entry:

nop
nop
nop
nop
nop
jmp T_1
nop
nop
EntryByte:
nop
nop
nop
T_1:

mov ax,cs
mov ds,ax
mov ss,ax
mov es,ax
mov sp,0xFFF0

; Write a test byte here
mov byte [ds:EntryByte],0xFA

vmcall ; Forces exit



