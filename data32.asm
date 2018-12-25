; --------------------------------------- 32 bit Data ---------------------------------------
SEGMENT DATA32 USE32

ldt_start:
ldt_1_descriptor  GDT_STR 0ffffh,0,0,92h,0cfh,0 ; 4GB 32-bit data
ldt_size=$-(ldt_1_descriptor)
; unlike the GDT , LDT does not have a 6-byte header to indicate its absolute address and limit ; these are specified into its GDT entry.
      
tssdata db 2048 dup (0) ; for some empty TSS
d32 dd 0


; --------------------------------------- 32 bit Page Segment ---------------------------------------
SEGMENT PAGE32 USE32
ORG 0

Page32Null dd 20000 DUP (0)

