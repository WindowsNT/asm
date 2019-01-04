FORMAT MZ

INCLUDE 'config.asm'
INCLUDE 'struct.asm'
INCLUDE 'data16.asm'
INCLUDE 'guest32.asm'
INCLUDE 'data32.asm'
INCLUDE 'data64.asm'
INCLUDE 'stack16.asm'
INCLUDE 'stack32.asm'
INCLUDE 'stack64.asm'
INCLUDE 'guest16.asm' 
INCLUDE 'code16.asm' 
INCLUDE 'a20.asm'
INCLUDE 'idt.asm'
INCLUDE 'gdt.asm'
INCLUDE 'code32.asm'
INCLUDE 'code64.asm'

SEGMENT ENDS 

entry CODE16:start16


