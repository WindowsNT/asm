

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

mmhelp db 'Commands: ',0xd,0xa,' (? or h) - help',0xd,0xa,' (g) - go',0xd,0xa,' (r) - registers',0xd,0xa,' (t) - trace',0xd,0xa,  ' (q) - quit',0xd,0xa,         "$"
mmj db 40,0
db 50 dup (0)
show dq 4096 dup (0)

bbb2 LoadX 0,0,0,0,0,0,0
rx db "d:\dism.exe",0

guestmode:
	vmr rax,0x6800 ; Guest CR0
	bt rax,1
	jz .noreal
		mov ax,0
		ret
	.noreal:
		mov ax,0x0100
ret


guestlinear:

	call guestmode

	vmr rax,0x681E ; Guest RIP
	vmr rbx,0x802 ; Guest CS
	shl rbx,4
	add rbx,rax
	mov rax,rbx
ret

bytecount dd 0

ShowDism:

	push rdi

	; rdi = where to store info
	;mov ax,dismdata2
	
	linear rsi,dismpos,DATA16
	xor ecx,ecx
	xor edx,edx
	mov dx,[rsi]
	mov cx,[rsi + 2]
	xor rdi,rdi
	mov di,cx
	shl edi,4
	add edi,edx

	; EDI = output

	push rdi
	call guestlinear

	; mode, 16 bit for now
	; The following is bad, we must check CS selector
	; but test for now
	push rax
	call guestmode
	cmp al,01
	jnz .nmx1
	mov byte [rdi],32
	jmp .ax1
	.nmx1:
	mov byte [rdi],16
	.ax1:
	pop rax
	
	; Check Mode actually
	; VMCALL
	linear rcx,exitreason,STACK64
	push rax
	mov al,[rcx]
	cmp al,18
	pop rax
	jnz .novmcall

	pop rdi
	pop rdi
	mov rax,'vmcall';
	stosq

	ret; nothing 

	.novmcall:

	push rax
	mov rcx,15
	mov byte [rdi + 1],15
	add rdi,2
	.jlpp:
	mov bl,[rax]
	mov [rdi],bl
	inc rax
	inc rdi
	dec rcx
	jrcxz .jlppf
	jmp .jlpp
	.jlppf:



	; call dism.exe
	mov bx,bbb2
	mov dx,rx
	mov bp,0x4B00
	mov si,CODE64
	shl esi,16
	mov edi,esi
	mov ax,0x421
	int 0xF0
	pop rax

	pop rdi
	mov rsi,rdi ; RSI now points to dissm bytes
	pop rdi		; RDI now to output buffer




	push rax
	.jlp:
	mov al,[rsi]
	cmp al,0
	jz .end
	stosb
	inc rsi
	jmp .jlp
	.end:
	pop rax

	; also the # of bytes
	push rdi
	linear rsi,dismposcount,DATA16
	xor ecx,ecx
	xor edx,edx
	mov dx,[rsi]
	mov cx,[rsi + 2]
	xor rdi,rdi
	mov di,cx
	shl edi,4
	add edi,edx
	mov esi,[edi]
	pop rdi

	; ESI = Count of bytes to transfer
	mov byte [rdi],' '
	mov byte [rdi+1],'('
	add rdi,2

	.jb1:
	cmp esi,0
	jz .jb2
	dec esi
	push rax
	mov al,[rax]
	call disp8
	pop rax
	inc rax
	jmp .jb1
	.jb2:

	mov byte [rdi],')'
	add rdi,1



ret

ShowCRs:

	;rax - rdx
	mov eax,'CR0 ';
	stosd
	mov rcx,5
	mov al,' '
	rep stosb
	
	mov eax,'CR3 ';
	stosd
	mov rcx,5
	mov al,' '
	rep stosb

	mov eax,'CR4 ';
	stosd
	mov rcx,5
	mov al,' '
	rep stosb

	mov ax,0x0D0A
	stosw

	vmr rax,0x6800 
	call disp32 
	mov al,' '
	stosb

	vmr rax,0x6802
	call disp32 
	mov al,' '
	stosb

	vmr rax,0x6804 
	call disp32 
	mov al,' '
	stosb

	mov ax,0x0D0A
	stosw



ret


ShowSegs:

	;DS 
	mov eax,'DS ';
	stosd
	mov al,' '
	stosb
	
	mov eax,'ES ';
	stosd
	mov al,' '
	stosb

	mov eax,'FS ';
	stosd
	mov al,' '
	stosb

	mov eax,'GS ';
	stosd
	mov al,' '
	stosb

	mov eax,'SS ';
	stosd
	mov al,' '
	stosb

	mov ax,0x0D0A
	stosw

	vmr rax,0x806
	call disp16 
	mov al,' '
	stosb

	vmr rax,0x800
	call disp16 
	mov al,' '
	stosb

	vmr rax,0x808
	call disp16 
	mov al,' '
	stosb

	vmr rax,0x80A
	call disp16 
	mov al,' '
	stosb

	vmr rax,0x804
	call disp16 
	mov al,' '
	stosb

	mov ax,0x0D0A
	stosw



ret
DisplayGuestMode:
	call guestmode
	cmp ah,0
	jnz .noreal
	mov eax,'RM ';
	stosd
	jmp .afterm
	.noreal:

	cmp ah,1
	jnz .noprot
	mov eax,'PM ';
	stosd
	jmp .afterm
	.noprot:

	.afterm:
ret

ShowRegs64:

	push64
	linear r15,vregs,STACK64
	linear rdi,show,CODE64
	cld

	call ShowCRs
	call ShowSegs

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

	; Mode
	call DisplayGuestMode

	; RIP
	mov rax,'CS:RIP  ';
	stosq
	vmr rax,0x802 ; Guest CS
	call disp16 
	mov al,':'
	stosb
	vmr rax,0x681E ; Guest RIP
	call disp64 
	mov al,' '
	stosb

	mov rax,'LINEAR  ';
	stosq
	call guestlinear
	call disp64 
	mov al,' '
	stosb

	
	mov al,' '
	stosb


	call ShowDism


	


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




ShowRegs:

	push64
	linear r15,vregs,STACK64
	linear rdi,show,CODE64
	cld

	call ShowCRs
	call ShowSegs

	;rax - rdx
	mov eax,'EAX ';
	stosd
	mov rcx,5
	mov al,' '
	rep stosb
	
	mov eax,'EBX ';
	stosd
	mov rcx,5
	mov al,' '
	rep stosb

	mov eax,'ECX ';
	stosd
	mov rcx,5
	mov al,' '
	rep stosb

	mov eax,'EDX ';
	stosd
	mov rcx,5
	mov al,' '
	rep stosb

	mov eax,'ESI ';
	stosd
	mov rcx,5
	mov al,' '
	rep stosb

	mov eax,'EDI ';
	stosd
	mov rcx,5
	mov al,' '
	rep stosb

	mov eax,'EBP ';
	stosd
	mov rcx,5
	mov al,' '
	rep stosb

	mov eax,'ESP ';
	stosd
	mov rcx,5
	mov al,' '
	rep stosb

	mov ax,0x0D0A
	stosw

	mov rax,[r15 + 0x00]
	call disp32
	mov al,' '
	stosb

	mov rax,[r15 + 0x08]
	call disp32
	mov al,' '
	stosb

	mov rax,[r15 + 0x10]
	call disp32
	mov al,' '
	stosb

	mov rax,[r15 + 0x18]
	call disp32
	mov al,' '
	stosb

	mov rax,[r15 + 0x20]
	call disp32
	mov al,' '
	stosb

	mov rax,[r15 + 0x28]
	call disp32
	mov al,' '
	stosb

	mov rax,[r15 + 0x30]
	call disp32
	mov al,' '
	stosb


	vmr rax,0x681C ; Guest RSP
	call disp32 
	mov al,' '
	stosb



	
	mov ax,0x0D0A
	stosw


	; Mode
	call DisplayGuestMode

	; RIP
	mov rax,'CS:EIP  ';
	stosq
	vmr rax,0x802 ; Guest CS
	call disp16 
	mov al,':'
	stosb
	vmr rax,0x681E ; Guest RIP
	call disp32
	mov al,' '
	stosb

	mov rax,'LINEAR  ';
	stosq
	call guestlinear
	call disp32 
	mov al,' '
	stosb

	mov al,' '
	stosb

	call ShowDism

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

	cmp byte [rdx + 2],'h'
	jz .CmdHelp

	cmp byte [rdx + 2],'r'
	jz .CmdRegs

	cmp byte [rdx + 2],'g'
	jz .CmdGo

	cmp byte [rdx + 2],'t'
	jz .CmdTrace

	cmp byte [rdx + 2],'q'
	jz .CmdQuit


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
		vmw32 0x4004,0x0 ; trap exception 0x06
		vmr rax,0x6820
		btr rax,8
		vmw64 0x6820,rax
		jmp .InputEnd

	.CmdTrace:
		; Set Trap
		vmw32 0x4004,0x2 ; trap exception 0x06 and 0x01
		vmr rax,0x6820
		bts rax,8
		vmw64 0x6820,rax
		jmp .InputEnd


	.CmdQuit:
		; Abort all
		jmp VmFinalCall

	.InputEnd:
ret


ShowDisplay:


call ShowRegs
call WaitForInput
ret











