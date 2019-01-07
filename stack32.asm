; --------------------------------------- 32 bit stack ---------------------------------------
SEGMENT STACK32 USE32
stack32         db      100 dup (?)
stack32_end:

if RESIDENT_OWN_PM_STACK = 0

stack32dmmi         db      200 dup (?)
stack32dmmi_end:

end if