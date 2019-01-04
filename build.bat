fasm entry.asm
fasm dmmic.asm
REM upx --best entry.exe
mkdir CD
del .\CD\entry.exe
del .\CD\dmmic.exe
copy entry.exe .\CD\entry.exe
copy dmmic.exe .\CD\dmmic.exe
powershell -ExecutionPolicy RemoteSigned -File "iso.ps1"

