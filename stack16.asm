; --------------------------------------- 16 bit stack ---------------------------------------
SEGMENT STACK16 USE16
sseg16 dw 1024 dup (?)
stack16_end:


;-------------------------------------------------------------------------------------------
; 16 bit stack segment for sipi
;-------------------------------------------------------------------------------------------
SEGMENT STACK16S USE16
ORG 0
sseg16s dw 200 dup (?)
stack16s_end:

sseg16dmmi dw 100 dup (?)
stack16dmmi_end:
		
sseg16dmmi2 dw 100 dup (?)
stack16dmmi2_end:

;-------------------------------------------------------------------------------------------
; 16 bit stack segments for threads
;-------------------------------------------------------------------------------------------
SEGMENT STACK16T1 USE16
ORG 0
sseg16t1 dw 200 dup (?)
stack16t1_end:
SEGMENT STACK16T2 USE16
ORG 0
sseg16t2 dw 200 dup (?)
stack16t2_end:
SEGMENT STACK16T3 USE16
ORG 0
sseg16t3 dw 200 dup (?)
stack16t3_end:
SEGMENT STACK16T4 USE16
ORG 0
sseg16t4 dw 200 dup (?)
stack16t4_end:
SEGMENT STACK16T5 USE16
ORG 0
sseg16t5 dw 200 dup (?)
stack16t5_end:
