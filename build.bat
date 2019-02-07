del d.iso
fasm entry.asm
fasm dpmic.asm
fasm dmmic.asm
fasm vdebug.asm
fasm mdebug.asm
fasm debuggee.asm
fasm leheader.asm le.exe

REM Wmake
REM Replace G:\WATCOM with your OpenWatcom Path
cd switcher
g:\watcom\binnt\wpp main.cpp -i="G:\WATCOM/h" -w4 -e25 -zq -od -d2 -bt=dos -fo=.obj -ml
g:\WATCOM\binnt\wlink libpath g:\watcom\lib286 libpath g:\watcom\lib286\dos name switcher d all op m op maxe=25 op q op symf file main.obj format dos 
cd ..

REM upx --best entry.exe
mkdir CD
copy /y vdebug.exe .\CD\
copy /y mdebug.exe .\CD\mdebug.exe 
copy /y debuggee.exe .\CD\debuggee.exe 
copy /y entry.exe .\CD\entry.exe 
copy /y dmmic.exe .\CD\dmmic.exe
copy /y dpmic.exe .\CD\dpmic.exe
copy /y .\switcher\switcher.exe .\CD\switcher.exe
copy /y le.exe .\CD\le.exe
copy /y runx.bat .\CD\runx.bat
powershell -ExecutionPolicy RemoteSigned -File "iso.ps1"
del .\CD\386swat.lod
copy swat\386swat.lod .\CD\386swat.lod
copy /y dos32a\* .\CD\ 
xcopy /y /s /e /i swat\* .\CD\swat
xcopy /y /s /e /i qlink\* .\CD\qlink
xcopy /y /s /e /i dpmi\* .\CD\dpmi
copy /y dis\dism.exe .\CD\

	