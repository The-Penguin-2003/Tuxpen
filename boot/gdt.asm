;;; Tuxpen GDT and TSS structures ;;;

%ifndef __TUXPEN_GDT_ASM__
%define __TUXPEN_GDT_ASM__

;; GDT selectors for real and protected mode
GDT32_Selector_Code32	equ 0x08	; 32-bit protected mode code
GDT32_Selector_Data32	equ 0x10	; 32-bit protected mode data
GDT32_Selector_Code16	equ 0x18	; 16-bit real mode code
GDT32_Selector_Data16	equ 0x20	; 16-bit real mode data

;; GDT selectors for long mode
GDT64_Selector_Kernel_Data	equ 0x08	; 64-bit long mode kernel data
GDT64_Selector_Kernel_Code	equ 0x10	; 64-bit long mode kernel code
GDT64_Selector_User_Data	equ 0x18	; 64-bit long mode user data
GDT64_Selector_User_Code	equ 0x20	; 64-bit long mode user code
GDT64_Selector_TSS		equ 0x28	; 64-bit task state segment

;; Global Descriptor Table (GDT)
struc GDT_Descriptor
	.LimitLow:		resw 1
	.BaseLow:		resw 1
	.BaseMiddle:		resb 1
	.Access:		resb 1
	.LimitHighFlags:	resb 1
	.BaseHigh:		resb 1
endstruc

;; 64-bit Task State Segment (TSS) Descriptor
struc TSS64_Descriptor
	.LimitLow:		resw 1
	.BaseLow:		resw 1
	.BaseMiddle:		resb 1
	.Access:		resb 1
	.LimitHighFlags:	resb 1
	.BaseHigh:		resb 1
	.BaseHighest:		resd 1
	.Reserved:		resd 1
endstruc

;; 64-bit Task State Segment (TSS)
struc TSS64
		resd 1	; Reserved
	.RSP0:	resq 1	; Stack pointer priv 0
	.RSP1:	resq 1	; ...
	.RSP2:	resq 1
		resq 1	; Reserved
	.IST1:	resq 1	; Interrupt stack table pointer 1
	.IST2:	resq 1	; ...
	.IST3:	resq 1
	.IST4:	resq 1
	.IST5:	resq 1
	.IST6:	resq 1
	.IST7:	resq 1
		resq 1	; Reserved
		resw 1	; Reserved
	.IOPB:	resw 1	; IO permission bitmap offset
endstruc

%endif ; __TUXPEN_GDT_ASM__
