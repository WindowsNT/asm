# Assembly Manual
Welcome to my assembly tutorials.

Articles:
* Real/Protected/Long mode : https://www.codeproject.com/Articles/45788/The-Real-Protected-Long-mode-assembly-tutorial-for
* Virtualization: https://www.codeproject.com/Articles/215458/Virtualization-for-System-Programmers
* Multicore DOS: https://www.codeproject.com/Articles/889245/Deep-inside-CPU-Raw-multicore-programming
* DMMI: https://www.codeproject.com/Articles/894522/Teh-Low-Level-M-ss-DOS-Multicore-Mode-Interface

At the moment, the first part is implemented (Real/Protected/Long mode), the Protected Mode Virtualization (working in Bochs) and the third part (test SIPI multicore, working on Bochs and VMWare)
More to follow soon.

## Instructions
1. Edit build.bat to specify flat assembler (FASM) path.
2. Edit startbochs.bat, startvmware.bat and startvbox.bat to locate the executables of these applications. Bochs is included
in the repository.

Build and run, it will automatically start bochs/vmware/virtualbox with the included FreeDOS image. 
It will create a CD-ROM as D: and you can run it from d:\entry.exe, by default it is automatically run (autoexec.bat)

## Tests performed
1. Real mode test
2. Protected mode test with or without paging
3. Long mode test with paging and PAE
4. Real mode thread calling
5. Real mode thread called from protected mode
6. Real mode thread called from long mode
7. Protected mode thread called from real mode
8. Long mode thread called from real mode
9. VMX is there
10. Spawn a Virtual Machine in Paged Protected Mode





