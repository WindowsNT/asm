; --------------------------------------- 64 bit Data ---------------------------------------
SEGMENT DATA64 USE64
ORG 0

d64 db 0


SEGMENT VMXDATA64 USE64

; --------------------------------------- VMX Data ---------------------------------------
ALIGN 4096
VMXStructureData db 20000 dup (0)
VMXStructureData1 dq 0 ; Used for VMXON
VMXStructureData2 dq 0 ; First VMCS
VMXStructureData3 dq 0 ; Second VMCS
VMXRevision dd 0 ; Save Revision here
VMXStructureSize dd 0 ; Save structure size here

; --------------------------------------- 64 bit Data another segment---------------------------------------
SEGMENT ABSD64 USE64

; --------------------------------------- 64 bit Page Directory ---------------------------------------
SEGMENT PAGE64 USE64
ORG 0

Page64Null dq 30000 dup (0)




