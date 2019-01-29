
@echo off
D:

entry.exe
entry.exe /r
dmmic.exe
dos32a.exe le.exe

cd dpmi
rem dpmione pro=dpmione.pro
cd ..

vdebug debuggee.exe
REM dism

mdebug debuggee.exe


a:


