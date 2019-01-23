# Assembly Manual
Welcome to my assembly tutorials.

Articles:
* Full article (all in one): https://www.codeproject.com/Articles/1273844/The-Intel-Assembly-Manual

Older Articles: 
* Real/Protected/Long mode : https://www.codeproject.com/Articles/45788/The-Real-Protected-Long-mode-assembly-tutorial-for
* Virtualization: https://www.codeproject.com/Articles/215458/Virtualization-for-System-Programmers
* Multicore DOS: https://www.codeproject.com/Articles/889245/Deep-inside-CPU-Raw-multicore-programming
* DMMI: https://www.codeproject.com/Articles/894522/Teh-Low-Level-M-ss-DOS-Multicore-Mode-Interface

At the moment, the first part is implemented (Real/Protected/Long mode), the Protected Mode Virtualization (working in Bochs), the third part (test SIPI multicore, working on Bochs and VMWare)
and the fourth part finished (DMMI). More to follow soon.

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
10. Spawn a Virtual Machine in Unrestricted guest mode. Paged Protected Mode guest also there.
11. Entry /r which installs as TSR the DMMI services
12. DMMI startup example taken from https://board.flatassembler.net/topic.php?t=7122
13. DMMIC app runs which demonstrates DMMI, launching real mode, protected mode, long mode and virtualized protected mode threads


## DMMI
I've called it DOS Multicore Mode Interface. It is a driver which helps you develop 32 and 64 bit multicore applications for DOS, using int 0xF0. 
This interrupt is accessible from both real, protected and long mode. Put the function number to AH.

To check for existence, check the vector for INT 0xF0. It should not be pointing to 0 or to an IRET, ES:BX+2 should point to a dword 'dmmi'.

Int 0xF0 provides the following functions to all modes (real, protected, long)

1. AH = 0, verify existence. Return values, AX = 0xFACE if the driver exists, DL = total CPUs, DH = virtualization support (0 none, 1 PM only, 2 Unrestricted guest). This function is accessible from real, protected and long mode.
2. AH = 1, begin thread. BL is the CPU index (1 to max-1). The function creates a thread, depending on AL:
   * 0, begin (un)real mode thread. ES:DX = new thread seg:ofs. The thread is run with FS capable of unreal mode addressing, must use RETF to return.
   * 1, begin 32 bit protected mode thread. EDX is the linear address of the thread. The thread must return with RETF.
   * 2, begin 64 bit long mode thread. EDX holds the linear address of the code to start in 64-bit long mode. The thread must terminate with RET.
   * 3, begin virtualized thread. BH contains the virtualization mode (1 for unrestricted guest real mode thread, and 2 for protected mode), and EDX the virtualized linear stack (or in seg:ofs format if unrestricted guest). The thread must return with RETF or VMCALL.
3. AH = 5, mutex functions. This function is accessible from all modes.
    * AL = 0 => initialize mutex to ES:DI (real) , EDI linear (protected), RDI linear (long).
    * AL = 1 => Lock mutex
    * AL = 2 => Unlock mutex
    * AL = 3 => Wait for mutex
4. AH = 4, execute real mode interrupt. This function is accessible from all modes. AL is the interrupt number, BP holds the AX value and BX,CX,DX,SI,DI are passed to the interrupt. DS and ES are loaded from the high 16 bits of ESI and EDI.
4. AH = 9, Switch To Mode.
	* From real mode: AL = 0 (enter unreal), AL = 2 (enter long, ECX = linear address to start. Code must set IDT found at [rax] on entry)
	* From long mode: AL = 0, go back to real, ECX = linear. 

Now, if you have more than one CPU, your DOS applications/games can now directly access all 2^64 of memory and all your CPUs, while still being able to call DOS directly. 

In order to avoid calling int 0xF0 directly from assembly and to make the driver compatible with higher level languages, an INT 0x21 redirection handler is installed. 
If you call INT 0x21 from the main thread, INT 0x21 is executed directly. If you call INT 0x21 from protected or long mode thread, then INT 0xF0 function AX = 0x0421 is executed automatically.

