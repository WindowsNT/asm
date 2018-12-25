SEGMENT CODE16 USE16
ORG 0h

; --------------------------------------- This is where the application starts ---------------------------------------
start16:

; --------------------------------------- Initialization of our segments ---------------------------------------
cli

;xchg bx,bx ; BOCHS magic breakpoint

mov ax,DATA16
mov ds,ax
mov es,ax
mov ax,STACK16
mov sp,stack16_end
mov ss,ax
sti

; --------------------------------------- Prepare Long Mode  ---------------------------------------
xor eax,eax
mov ax,CODE64
shl eax,4
add eax,Start64
push fs
mov bx,CODE32
mov fs,bx
mov dword [fs:PutLinearStart64],eax
pop fs


; --------------------------------------- Real mode test ---------------------------------------
mov ax,0900h
mov dx,rm1
int 21h

; --------------------------------------- Protected Mode Test ---------------------------------------
mov bx,idt_RM_start
sidt [bx]
call EnableA20
call GDTInit
call IDTInit
cli
mov bx,gdt_start
lgdt [bx]
mov bx,idt_PM_start
; = NO DEBUG HERE =
lidt [bx]
mov eax,cr0
or al,1
mov cr0,eax 
db  066h  
db  0eah 
dd  Start32
dw  code32_idx
 
; --------------------------------------- Exit ---------------------------------------

exit16:
mov     eax,cr0         
and     al,not 1        
mov     cr0,eax         
db      0eah
dw      flush_ipq,CODE16
flush_ipq:
mov     ax,STACK16 
mov     ss,ax
mov     sp,stack16_end
mov ax, DATA16
mov     ds,ax
mov     es,ax
mov     di,idt_RM_start
lidt    [di]
sti
; = END NO DEBUG HERE =

; --------------------------------------- Tests ---------------------------------------
mov ax,DATA32
mov gs,ax
cmp [gs:d32],1
jnz fail_1
mov dx,pm1
mov ax,0900h
int 21h
fail_1:

; --------------------------------------- Bye! ---------------------------------------
mov ax,4c00h
int 21h

