
; VMX Entry for our Virtual Machine
; This is a Protected Mode segment

StartVM3: ; This is a protected mode start - 32 bit so registers are already loaded

xchg bx,bx
vmcall ; Forces exit
