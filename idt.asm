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


  ; 00h
  mov ecx,255
  xor edi,edi
  mov di,interruptsall

  Loop1:
  
  mov bp,8
  mov ax,cx
  mul bp
  mov bp,ax
  
  xor eax,eax


  cmp cx, 15
  jnz .nof0
  add eax,int32
  jmp .cf0
  .nof0:

  add eax,intr00
  .cf0:

  ;  mov [ds:interruptsall[bp].o0_15],ax
  ;shr     eax,16
  ;mov     [ds:interruptsall[bp].o16_31],ax
  ;mov [ds:interruptsall[bp].se0_15],code32_idx
  ;mov [ds:interruptsall[bp].zb],0
  ;mov [ds:interruptsall[bp].flags],08Eh ; 10001110 selector
  
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
 
  jcxz EndLoop1
  dec cx
  jmp Loop1
  EndLoop1:
  

  ; Set idt ptr
  xor eax,eax
        mov     ax,DATA16
        shl     eax,4
        add     ax,interruptsall
        mov     [idt_PM_ptr],eax

  RETF