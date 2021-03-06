; --------------------------------------- 32 bit Data ---------------------------------------
SEGMENT DATA32 USE32

ldt_start:
ldt_1_descriptor  GDT_STR 0ffffh,0,0,92h,0cfh,0 ; 4GB 32-bit data
ldt_size=$-(ldt_1_descriptor)
; unlike the GDT , LDT does not have a 6-byte header to indicate its absolute address and limit ; these are specified into its GDT entry.
      
tssdata db 2048 dup (0) ; for some empty TSS
d32 dd 0


; --------------------------------------- MOVEMENTS FOR INT0xF0 ---------------------------------------
From32To16Regs db 64 dup (0)


