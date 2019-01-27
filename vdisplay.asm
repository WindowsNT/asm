

disp64:
	push rax
	shr rax,32
	call disp32
	pop rax
disp32:
	push rax
	shr eax,16
	call disp16
	pop rax
disp16:
	push ax
	mov al,ah
	call disp8
	pop ax
disp8:
	push ax
	push cx
	mov cl,4
	shr al,cl
	call disp4
	pop cx
	pop ax
disp4:
	and al,0fh
	cmp al,0xA
	jae .hdisp4

	add al,0x30
	stosb
	ret

	.hdisp4:
	sub al,0xA
	add al,0x41
	stosb
ret

mmhelp db 'Commands: ',0xd,0xa,' (?) - help',0xd,0xa,' (g) - go',0xd,0xa,' (r) - registers',0xd,0xa,' (t) - trace',0xd,0xa,          "$"
mmj db 40,0
db 50 dup (0)
show dq 4096 dup (0)

ShowRegs:

	push64
	linear r15,vregs,STACK64
	linear rdi,show,CODE64
	cld

	;rax - rdx
	mov eax,'RAX ';
	stosd
	mov rcx,13
	mov al,' '
	rep stosb

	mov eax,'RBX ';
	stosd
	mov rcx,13
	mov al,' '
	rep stosb

	mov eax,'RCX ';
	stosd
	mov rcx,13
	mov al,' '
	rep stosb

	mov eax,'RDX ';
	stosd
	mov rcx,13
	mov al,' '
	rep stosb

	mov ax,0x0D0A
	stosw

	mov rax,[r15 + 0x00]
	call disp64
	mov al,' '
	stosb

	mov rax,[r15 + 0x08]
	call disp64
	mov al,' '
	stosb

	mov rax,[r15 + 0x10]
	call disp64
	mov al,' '
	stosb

	mov rax,[r15 + 0x18]
	call disp64
	mov al,' '
	stosb

	mov ax,0x0D0A
	stosw

	; RSI RDI RBP RSP
	mov eax,'RSI ';
	stosd
	mov rcx,13
	mov al,' '
	rep stosb

	mov eax,'RDI ';
	stosd
	mov rcx,13
	mov al,' '
	rep stosb

	mov eax,'RBP ';
	stosd
	mov rcx,13
	mov al,' '
	rep stosb

	mov eax,'RSP ';
	stosd
	mov rcx,13
	mov al,' '
	rep stosb

	mov ax,0x0D0A
	stosw

	mov rax,[r15 + 0x20]
	call disp64
	mov al,' '
	stosb

	mov rax,[r15 + 0x28]
	call disp64
	mov al,' '
	stosb

	mov rax,[r15 + 0x30]
	call disp64
	mov al,' '
	stosb

	vmr rax,0x681C ; Guest RSP
	call disp64 
	mov al,' '
	stosb

	mov ax,0x0D0A
	stosw

	; RIP
	mov rax,'CS:RIP: ';
	stosq
	vmr rax,0x802 ; Guest CS
	call disp16 
	mov al,':'
	stosb
	vmr rax,0x681E ; Guest RIP
	call disp64 
	mov al,' '
	stosb

	mov eax,'NEXT';
	stosd
	mov al,' '
	stosb
;	vmr rax,0x681E ; Guest RIP
;	mov rax,[rax]
;	call disp64 

	


	mov ax,0x0D0A
	stosw


	mov al,'$'
	stosb
	mov dx,show
	mov si,CODE64
	shl esi,16
	mov ebp,0x900
	mov ax,0x421
	int 0xF0

	pop64

ret

ShowPrompt:
	push64
	linear rdi,show,CODE64
	cld
	mov ax,0x0D0A
	stosw
	mov al,'*'
	stosb
	mov al,' '
	stosb
	mov al,'$'
	stosb
	mov dx,show
	mov si,CODE64
	shl esi,16
	mov ebp,0x900
	mov ax,0x421
	int 0xF0
	pop64
ret

WaitForInput:
	call ShowPrompt

	mov dx,mmj
	mov si,CODE64
	shl esi,16
	mov ebp,0xa00
	mov ax,0x421
	int 0xF0
	linear rdx,mmj,CODE64
	mov al,[rdx + 1]
	cmp al,0 ; nothing entered?
	jz WaitForInput

	; Single Byte Commands
	cmp byte [rdx + 2],'?'
	jz .CmdHelp

	cmp byte [rdx + 2],'r'
	jz .CmdRegs

	cmp byte [rdx + 2],'g'
	jz .CmdGo

	cmp byte [rdx + 2],'t'
	jz .CmdTrace

	jmp WaitForInput


	.CmdRegs:
		call ShowRegs
	jmp WaitForInput

	.CmdHelp:
		mov dx,mmhelp
		mov si,CODE64
		shl esi,16
		mov ebp,0x900
		mov ax,0x421
		int 0xF0
	jmp WaitForInput

	.CmdGo:
		; Clear Trap
		vmw32 0x4004,0 ; allow exceptions
		vmr rax,0x6820
		btr rax,8
		vmw64 0x6820,rax
		jmp .InputEnd

	.CmdTrace:
		; Set Trap
		vmw32 0x4004,2 ; block intx1
		vmr rax,0x6820
		bts rax,8
		vmw64 0x6820,rax
		jmp .InputEnd

	.InputEnd:
ret


ShowDisplay:

call ShowRegs
call WaitForInput
ret











