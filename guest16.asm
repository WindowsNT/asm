SEGMENT VMX16 USE16



; VMX Entry for our Virtual Machine
; This is a Real Mode segment

; Note that since the memory is see through, BIOS and DOS interrupts work here!

StartVM:

; Remember we used a protected mode selector to get here?
; Jump to a real mode segment now so CS gets a proper value

nop
nop

db 0eah
dw PM_VM_Entry,VMX16
PM_VM_Entry:

mov ax,DATA16
mov ds,ax
mov [vmt3],1

vmcall ; Forces exit



