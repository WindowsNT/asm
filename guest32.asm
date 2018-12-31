SEGMENT VMX32 USE32

; VMX Entry for our Virtual Machine
; This is a Protected Mode segment

StartVM2: ; This is a protected mode start - 32 bit so registers are already loaded


nop
nop
nop

nop
nop
jmp T_2
nop
nop
EntryByte2:
nop
nop
nop
T_2:


; Write a test byte here
;mov byte [ds:EntryByte2],0xFA

vmcall ; Forces exit






