SEGMENT VMX32 USE32

; VMX Entry for our Virtual Machine
; This is a Protected Mode segment

StartVM2: ; This is a protected mode start - 32 bit so registers are already loaded

mov ax,data16_idx
mov ds,ax
mov byte [ds:vmt2],0x1
vmcall ; Forces exit






