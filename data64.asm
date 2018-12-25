; --------------------------------------- 64 bit Data ---------------------------------------
SEGMENT DATA64 USE64

; --------------------------------------- 64 bit Data another segment---------------------------------------
SEGMENT ABSD64 USE64

; --------------------------------------- 64 bit Page Directory ---------------------------------------
SEGMENT PAGE64 USE64

ORG LONGPAGEORGBASE

; 4096 bytes for PML4
PML4_64 db 4096 dup (?)

; 4096 bytes of PDP_64
PDP_64 db 4096 dup (?)

; 4096 bytes of PD_64
PD_64 db 4096 dup (?)
; 
PAGE_64 dq 4096 dup (?)
; 32768 Bytes = 4096 Pages = 4096*4096 = 16MB (Each page takes 8 bytes)

