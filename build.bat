fasm entry.asm
mkdir CD
del .\CD\entry.exe
copy entry.exe .\CD\entry.exe
oscdimg.exe -h .\CD .\d.iso
