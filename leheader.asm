;
; FASM example of creation of a linear ( exponential soon Very Happy )
; executable ("LE") for running on DOS/32A extender.
;
; Compiles directly from .ASM into .LE , no linker Very Happy
;
; Use "SB" tool to bind it with the extender.
;
; http://board.flatassembler.net/topic.php?t=7122
;
; Limitations:
; - No relocs (crappy anyway)
; - Only one "object" ( no problem, flat rules Very Happy )
;
; Size should be no problem, tested with 2 MiB, should
; support up to 2 Gib Wink
;

format binary as "LE"
use32
org 0

; *** Constants ***

ccstackp = 2 ; Stack size in pages ( 1 page = 4 KiB )

; *** Calculations ***

vvstackb = ccstackp shl 12		  ; Pages -> Bytes
vvcodesize = llcodeend - llcode
vvcodep = ( vvcodesize + $0FFF ) shr 12 ; Bytes -> Pages
vvpagestotal = vvcodep + ccstackp
vvpagestotalali = ( vvpagestotal + 3 ) and $000FFFFC ; Align to integer multi of 4

vvcodepad = 2 ; Allign code size to integer multi of $10, and add 2 to make loader / DOS happy
vvtemp1 = vvcodesize and $0F ; Temp, find out used bytes on last 16-Bytes block
if vvtemp1 > 0
  vvcodepad = 18 - vvtemp1
end if

; *** LE / [LX] "Module Header" (0,$AC) ***

;org 0
db "LE"
db 0,0		    ; Little endian, surprisingly Very Happy
db 0,0,0,0    ; "level" ... of zeroizm
db 2,0		   ; 80386
db 1,0	     ; "OS/2" Osama's System Very Happy
db 0,0,0,0    ; "module version"
; org $10
dd 0		   ; "module type", crap
dd vvpagestotal   ; Number of pages total
dd 1,0			; CS:EIP object number (4 bytes) & offset (4 bytes)
; org $20
dd 2, vvstackb	    ; SS:ESP object number (4 bytes) & offset (4 bytes)
dd $1000	 ; Page size in bytes
dd 0		; LX: "shift" alignement (4 -> $10 bytes) | LE: bytes on last page | crap Sad
; org $30
dd vvpagestotalali shl 2 , 0
; "fixup" size, chk | "size" may NEVER be 0 !!! Can be skipped in LE, but not empty
dd $30,0      ; "loader" size, chk
; org $40
dd $B0		 ; Offset of the "Object table" (relative to "LE")
dd 2	       ; Number of entries
dd $E0		 ; LX: Offset of the "Object Page Table" | LE: Offset of object "Map" !!!
dd 0		; Offset of ??? , "iterate" crap
; org $50
dd 0	     ; Offset ressource table
dd 0	    ; Number of entries
dd 0		 ; Offset "resident" crap
dd 0		  ; Offset of "entry" crap table Sad
; org $60
dd 0,0		   ; "MD" offset & entries, useless junk Very Happy
dd $E0		 ; Fixup offset 1, important in LX only !!!
dd $E0		  ; Fixup offset 2, useless junk both LE and LX Wink
; org $70
dd 0,0		  ; Import offset, count, both junk
dd 0,0		   ; 2 more offsets, crap
; org $80
dd llcode     ; "Data pages offset" - where the code begins, relative to MZ, not "LE" !!!
	; "SB" will care when binding ... just v. 7.1 won't - it has a BUG !!! Sad
dd 0,0,0      ; Some more crap
; org $90
dd 0,0,0,0    ; Useless "chk", "auto", 2 x deBUG
; org $A0
dd 0,0,0      ; Crap / "heap"

; *** Reserved / crap ($AC,4) ***

dd 0

; *** Object table entry #1 ($B0,$18 ) (main) ***

; Flags can be $2045 (R) or $2047 (R&W)

dd vvcodep shl 12 ; Size in bytes (we always align to 4 KiB)
dd 0	       ; Base address won't work, let's set it to most funny value of 0
dd $2047	  ; Flags: "huge 32-bit" | "preloaded" | "executable" | "writable" | "readable"
dd 1,vvcodep	 ; "map" index (count from 1 ???) / entries
dd 0		; Reserved / crap

; *** Object table entry #2 ($C8,$18 ) (stack) ***

; !!! Stack may *** NEVER *** be executable !!!

dd ccstackp shl 12    ; Size in bytes
dd 0			 ; Base address won't work
dd $2043	  ; Flags: "huge 32-bit" | "preloaded" | "writable" | "readable"
dd 1+vvcodep,ccstackp ; "map" index / entries
dd 0		       ; Reserved / crap

; *** Object Page Map ($E0,n*$10 ) | Fixup 1st Table | Fixup 2nd Table ***

dd vvpagestotalali dup (0)   ; Crap, one "dd" zero needed per page

macro laddr reg,ofs
{
	local thiscall
	call thiscall
	thiscall:
	pop reg
	add reg,ofs-thiscall
}


; *** Code, forget about "org", never loads correctly Wink ***
; "org" $F0 minimum, always $10 bytes aligned

llcode:

include 'lemain.asm'

llcodeend:

db vvcodepad dup (0)   ; Crap, to prevent unexpected EOF

;end.