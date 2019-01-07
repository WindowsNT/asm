; --------------------------------------- IDT routines ---------------------------------------
USE16
IDTInit2:

 ; Base for intr00 -> All vectors point to this, except f0
 xor edx,edx
 mov dx,CODE32
 shl edx,4
 add edx,intr00 ; EDX now contains physical address for handler


 
 mov cx,255
 xor esi,esi
 mov si,interruptsall
 Loop1a:
 
 ; 
 push edx
 cmp cx, 15
 jnz .nof0
 linear edx,int32,CODE32
  .nof0:
 mov edi,esi
 mov eax,edx
 mov word [edi],ax ; lower
 add edi,2
 mov word [edi],code32_idx ; sel
 add edi,2
 mov byte [edi],0
 add edi,1
 mov byte [edi],08Eh; 
 add edi,1
 mov eax,edx
 shr eax,16
 mov word [edi],ax ; upper
 
 pop edx
 
 
 jcxz EndLoop1a
 dec cx
 add esi,8
 jmp Loop1a
 EndLoop1a:
 
 
  ; Set idt ptr
  xor eax,eax
  mov     ax,DATA16
  shl     eax,4
  add     ax,interruptsall
  mov     [idt_PM_ptr],eax

 

retf
 


 IDTInit:

  push es

  mov ax,DATA16
  mov es,ax

  ; 00h
  mov ecx,255
  xor edi,edi
  mov di,interruptsall
  
  .Loop1:
  
  mov bp,8
  mov ax,cx
  mul bp
  mov bp,ax
  
  xor eax,eax


  cmp cx, 0x0F
  jz .yf0
  cmp cx, 0xDE
  jz .y21

  add eax,intr00
  jmp .ef

  .y21:
  add eax,int32_21
  jmp .ef

  .yf0:
  add eax,int32
  jmp .ef

  .ef:
  mov [di],ax
  shr eax,16
  mov [di + 6],ax
  mov ax,code32_idx
  mov [di + 2],ax
  xor ah,ah
  mov [di + 4],ah
  mov ah,08eh
  mov [di + 5],ah; 10001110 selector
  
  add di,8
 
  jcxz .EndLoop1

  dec cx
  jmp .Loop1
  .EndLoop1:
  

	; Set idt ptr
	xor eax,eax
	mov     ax,DATA16
	shl     eax,4
	add     ax,interruptsall
	mov     [idt_PM_ptr],eax

	pop es
  RETF



  

 IDTInit64:

  push es

  mov ax,DATA16
  mov es,ax

  ; 00h
  mov ecx,0
  xor edi,edi
  mov di,interruptsall64
  
  .Loop1:

  cmp ecx,0x100
  jz .End

  linear eax,intr6400,CODE64
  
  cmp ecx,0xF0
  jz .yf0
  cmp ecx,0x21
  jz .y21

  .yf0:
  linear eax,int64,CODE64
  jmp .ef0

  .y21:
  linear eax,int64_21,CODE64
  jmp .ef0

  .ef0:

  ; 0(2) - Low bits offset
  mov word [di],ax
  ; 2(2) - Selector
  mov word [di + 2],code64_idx
  ; 4(1) - zero
  mov byte [di + 4],0
  ; 5(1) - Type + Attributes
  mov byte [di + 5],0x8E
  ; 6(2) - Middle offset
  mov edx,eax
  shr edx,16
  mov word [di + 6],dx
  ; 8(4) High bits
  mov dword [di + 8],0
  ; 12(4) zero
  mov dword [di + 12],0


  add di,16
  inc ecx
  jmp .Loop1

  
  .End:

  ; Set idt ptr
  linear eax,interruptsall64
  mov     dword [idt_LM_ptr],eax
  mov     dword [idt_LM_ptr + 4],0
  
  pop es
  RETF

