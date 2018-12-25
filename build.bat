fasm entry.asm
mkdir CD
del .\CD\entry.exe
copy entry.exe .\CD\entry.exe
powershell -ExecutionPolicy RemoteSigned -File "iso.ps1"

