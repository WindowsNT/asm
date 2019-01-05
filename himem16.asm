
himaddrx:
himaddr dd 0

himemthere:

mov ax,0x4300
int 0x2F
cmp al,0x80
jz .hi

ret
.hi:

mov ax,0x4310
int 0x2F
mov word [cs:himaddrx + 2],es
mov word [cs:himaddrx],bx

mov al,0x80
ret

allochigh: ; EDX = bytes, return ECX = handle, EDI = linear

xor ecx,ecx
cmp [cs:himaddr],0
jnz .useh

.noh:
mov ecx,0
mov edi,0
ret

.useh:

mov ax,0x0900
shr edx,10
call far [cs:himaddr]
cmp dx,0
jz .noh

mov ax,0x0C00
mov cx,dx
xor edx,edx
xor ebx,ebx
mov dx,cx
call far [cs:himaddr]
cmp ax,1
jz .okh

mov ax,0x0A00
mov dx,cx
call far [cs:himaddr]
jmp .noh

.okh:
xor edi,edi
mov di,dx
shl edi,16
add edi,ebx


ret

freehigh: ; DX = handle

cmp dx,0
jz .noh

cmp [cs:himaddr],0
jnz .useh

.noh:

ret

.useh:

mov ax,0x0D00
call far [cs:himaddr]

mov ax,0x0A00
call far [cs:himaddr]

ret