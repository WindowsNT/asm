# Assembly Manual
Welcome to my assembly tutorials.

Articles:
* Real/Protected/Long mode : https://www.codeproject.com/Articles/45788/The-Real-Protected-Long-mode-assembly-tutorial-for
* Virtualization: https://www.codeproject.com/Articles/215458/Virtualization-for-System-Programmers
* Multicore DOS: https://www.codeproject.com/Articles/889245/Deep-inside-CPU-Raw-multicore-programming
* DMMI: https://www.codeproject.com/Articles/894522/Teh-Low-Level-M-ss-DOS-Multicore-Mode-Interface

At the moment, the first part is implemented (Real/Protected/Long mode). More to follow

## Instructions
1. Edit build.bat to specify flat assembler (FASM) path.
2. Edit startbochs.bat, startvmware.bat and startvbox.bat to locate the executables of these applications. Bochs is included
in the repository.

Build and run, it will automatically start bochs/vmware/virtualbox with the included FreeDOS image. 
It will create a CD-ROM as D: and you can run it from d:\entry.exe, by default it is automatically run (autoexec.bat)





