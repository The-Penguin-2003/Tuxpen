;;; Tuxpen global variables used by the bootloader ;;;

%ifndef __TUXPEN_GLOBALS_ASM__
%define __TUXPEN_GLOBALS_ASM__

%include "boot/mem.asm"

;; Global variables
struc Globals, Mem_Globals
	.DriveNumber: 		resd 1
	.RootDirectorySector: 	resw 1
	.KernelSector:		resw 1
	.KernelSize:		resd 1
	.CPUFeatureBitsECX:	resd 1
	.CPUFeatureBitsEDX:	resd 1
endstruc

%endif	; __TUXPEN_GLOBALS_ASM__
