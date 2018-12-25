# Assembly Manual
Welcome to my assembly tutorials.

Articles:
* Real/Protected/Long mode : https://www.codeproject.com/Articles/45788/The-Real-Protected-Long-mode-assembly-tutorial-for
* Virtualization: https://www.codeproject.com/Articles/215458/Virtualization-for-System-Programmers
* Multicore DOS: https://www.codeproject.com/Articles/889245/Deep-inside-CPU-Raw-multicore-programming
* DMMI: https://www.codeproject.com/Articles/894522/Teh-Low-Level-M-ss-DOS-Multicore-Mode-Interface

At the moment, the first part is implemented (Real/Protected/Long mode). More to follow

## Instructions
1. Put flat assembler (https://flatassembler.net/) to the path, or edit build.bat to include a path
2. In Project Properties -> Debugger, put the BOCHSDBG.EXE path to command to run

Build and run, it will automatically start bochs with the included FreeDOS image. It will create a CD-ROM as R: and you can run it.
You have also a VMWare configuration to test


