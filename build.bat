del d.iso
fasm entry.asm
fasm dmmic.asm
fasm vdebug.asm
fasm mdebug.asm
fasm debuggee.asm
fasm leheader.asm le.exe
REM upx --best entry.exe
mkdir CD
copy /y vdebug.exe .\CD\vdebug.exe 
copy /y mdebug.exe .\CD\mdebug.exe 
copy /y debuggee.exe .\CD\debuggee.exe 
copy /y entry.exe .\CD\entry.exe 
copy /y dmmic.exe .\CD\dmmic.exe
copy /y le.exe .\CD\le.exe
powershell -ExecutionPolicy RemoteSigned -File "iso.ps1"
del .\CD\386swat.lod
copy swat\386swat.lod .\CD\386swat.lod
copy /y dos32a\* .\CD\ 
xcopy /y /s /e /i swat\* .\CD\swat
