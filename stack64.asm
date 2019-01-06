; --------------------------------------- 64 bit stack ---------------------------------------

SEGMENT STACK64 USE64
ORG 0
stack64         db      1000 dup (?)
stack64_end:


stack64dmmi         db      1000 dup (?)
stack64dmmi_end:
