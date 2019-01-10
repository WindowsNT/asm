del d.iso
fasm entry.asm
fasm dmmic.asm
REM upx --best entry.exe
mkdir CD
del .\CD\entry.exe
copy entry.exe .\CD\entry.exe
del .\CD\dmmic.exe
copy dmmic.exe .\CD\dmmic.exe
powershell -ExecutionPolicy RemoteSigned -File "iso.ps1"
del .\CD\386swat.lod
copy swat\386swat.lod .\CD\386swat.lod
copy /y dos32a\* .\CD\ 
