DPMIONE  -- A DPMI 1.0 Host -- Version 0.91
(C) Copyright 1990-2004 Qualitas, Inc.	All Rights Reserved.


Overview
--------

The DOS Protected Mode Interface (DPMI) Specification version 0.9 was
created by the DPMI Committee in 1990, and extended to version 1.0 in
1991.  From the introduction to the DPMI 1.0 spec, "The DOS Protected
Mode Interface (DPMI) allows DOS programmers to access the advanced
features of 80286, 80386, and 80486-based PCs in a well-behaved,
hardware-independent fashion that does not compromise system
protection".  With this spec, it becomes especially easy to write a
program which enters Protected Mode (PM), and has access to all of the
system's extended memory.

DPMI 0.9 hosts are readily available, standalone or otherwise.	Some
DPMI 0.9 hosts implemented a handful of DPMI 1.0 features, but other
than 386MAX, none of them did the whole spec.

DPMIONE is, to my knowledge, the first publicly available standalone
DPMI 1.0 host.	This program is an outgrowth of the DPMI 1.0 host
which first appeared in 386MAX from Qualitas, Inc. in 1992.  As such,
it has undergone extensive testing in that commercial product before
being ported to this standalone program.



Features
--------

* Supports DPMI 1.0 (superset of DPMI 0.9)
* Starts from either Real Mode or Virtual Mode (using VCPI)
* Low DOS memory resident size is about 15KB
* Extended memory resident size is about 300KB plus Page Tables (4KB
  per 4MB of physical memory)
* Loads from command line or as device driver so subsequently loaded
  device drivers can use DPMI
* Supports both 16-bit and 32-bit DPMI clients
* Supports nested DPMI clients
* Supports uncommitted memory (a very handy DPMI 1.0 feature)
  (See the file UNCOMMIT.TXT for details.)
* Full DOS (INT 21h) & Mouse (INT 33h) translation services
* Swapfile support
* Compatible with 386SWAT for debugging DPMI clients


System Requirements
-------------------

* 80386 CPU or later
* XMS driver (HIMEM.SYS or Memory Manager EMM386/QEMM/etc. --
  386MAX 7 and later versions already support DPMI 1.0)


Limitations
-----------

* VM/RM exceptions 06h (Invalid Opcode) and 0Dh (GP Fault) only are
  reflected to PM.
* The TSR facility of DPMI 1.0 is not supported.


Installation
------------

1.  Unzip the files into a separate directory (say, C:\DPMIONE).

2.  Edit the file DPMIONE.PRO to include a line which loads the
    DPMI.LOD file, e.g.

    load=c:\dpmione\dpmi.lod pro=c:\dpmione\dpmi.pro

3.  Edit the DPMI.PRO file as necessary (no changes are needed from
    the defaults).

4.  Decide whether you want to load DPMIONE.EXE in your CONFIG.SYS or
    AUTOEXEC.BAT file (or neither).  Then, do either step 4a or 4b
    (but *NOT BOTH*):

    a.	Edit your CONFIG.SYS file to include a line such as

	Device=c:\dpmione\dpmione.exe pro=c:\dpmione\dpmione.pro

    b.	Edit your AUTOEXEC.BAT file to include a line such as

	c:\dpmione\dpmione pro=c:\dpmione\dpmione.pro

    c.	If you chose not to load DPMIONE automatically, you can run it
	from the command line at a later time, with a line similar to
	the one in 4b.

5.  If necessary, reboot your system to load DPMIONE.


Compatibility
-------------

As a test of this program's compatibility as a DPMI host, you can
actually use it as a substitute for the Windows 3.1x DPMI host.  That
is, install a fresh copy of Windows 3.1x.  Then, with DPMIONE resident,
go to the WINDOWS directory and type

	system\krnl386

and Windows is up and running.	This instance of Windows does not
support DOS sessions or anything related to that, but most other
Windows functions are there including File Manager.  This has proven
to be an exceptionally rigorous test of a DPMI host.  No other
unrelated DPMI host can make this claim.


Expand Down Stacks
------------------

The Locked Protected Mode stack used by DPMIONE for hardware
interrupts and faults is marked as Expand Down so it expands
automatically.	In the process of making this work, I learned a lot.
For more details on Expand Down segments, see
http://www.sudleyplace.com/dpmione/expanddown.htm.


Author & Copyright
------------------

This program was written by Bob Smith (bsmith@sudleyplace.com) and is
(C) Copyright 1990-2004 Qualitas, Inc.	The most recent version may be
found at http://www.sudleyplace.com/dpmione/.


License
-------

This program may be used free for non-commercial use; commercial use
requires a volume purchase agreement from the author.  It may be
freely distributed as long as no part of the program or its
documentation is altered and the program and its documentation are
kept together.


Download
--------

The program files may be downloaded from our FTP site at
ftp://ftp.sudleyplace.com/sudleyplace/dpmione.zip.


Specification
-------------

To view the DPMI 1.0 specification, try one of the following links:

http://www.delorie.com/djgpp/doc/dpmi/ (HTML)
http://clio.rice.edu/cwsdpmi/dpmispec1.pdf (PDF)


Version History
---------------

Please see the file VERSION.TXT.

