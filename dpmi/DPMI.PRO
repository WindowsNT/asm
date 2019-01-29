; Profile for DPMI.LOD
;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
; Options currently in effect are


;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
; Default options are

; dpmimem=616,1024,4096,32,32,1,2048 ; Set DPMI memory options
; sharedmem=16		; Set the Shared Memory size to nnnn MB

;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
; All possible options recognized by DPMI.LOD are

; debug=cli		; Don't disable interrupts on CLI in PM
; debug=dpmierr 	; Signal INT 01h on each DPMI error
; debug=dpmilock	; Check for InDOS when paging
; debug=dpminewsel	; Force new selector on all allocates
; debug=dpmiphys	; Disable checks in DPMI_GETP2L
; debug=dpmisel 	; Signal INT 01h on each LAST_DPMI_xS error
; debug=dpmispurnt	; Signal INT 01h on spurious NT task switches
; debug=dpmistart	; Signal INT 01h on DPMI client startup
; debug=dpmistd 	; Force KRNL386 to come up in standard mode
; debug=dpmiterm	; Signal INT 01h if we free resources upon termination
; debug=dpmiv100	; Force DPMI version 1.00 even if Rational Systems-based app
; debug=nodebug 	; Disable hooks for INTs 01h and 03h for debugging purposes
; debug=nokeyb		; Disable hook	for INT  09h	       for debugging purposes
; debug=nonmi		; Disable hook	for INT  02h	       for debugging purposes
; debug=nowrap		; Trap even boundary stack wraps at 0000
; dpmimem=lll,sss,bbb,ccc,hhh,ppp,ddd ; Set DPMI memory options:      Min   Def
;			  lll = # LDT entries			       32   616
;			  sss = byte size of the HPDA stack	      512  1024
;			  bbb = byte size of the HPDA buffer	      512  4096
;			  ccc = # VM callbacks			       16    32
;			  hhh = # DPMI memory handles			1    32
;			  ppp = # page directories			1     1
;			  ddd = byte size of the dynamic save area   1024  2048
; forcelpm16		; Force the LPM stack to be 16-bit (overcome bug in MS linker)
; noumb 		; Don't allocate memory in UMBs
; novcpi		; Disable VCPI presence detection
; pro=d:\path\filename.ext ; Load a profile (cannot be used from within a profile)
; sharedmem=nnnn	; Set the Shared Memory size to nnnn MB
;			; (default = 16 MB, must be multiple of 4 MB)
; swapfile [=d:\path\filename.ext] [/s=nnnn] [/t] [/p] ; Use a swapfile for DPMI VMM
;		  optional args
;		  d:\path\filename.ext	 Use this as permanent swapfile
;		  /p			 Make it permanent
;		  /t			 On second thought, it's temporary
;		  /s=nnnn		 Make it nnnn KB in size (default = 8192)
;		  If no filename is specified, the SWAPFILE is temporary
;		    unless /P is specified.  Otherwise, it's permanent
;		    unless /T is specified.

