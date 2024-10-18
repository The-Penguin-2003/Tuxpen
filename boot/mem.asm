;;; Tuxpen memory layout constants used by the bootloader ;;;

%ifndef __TUXPEN_MEM_ASM__
%define __TUXPEN_MEM_ASM__

;; Memory Layout
Mem_BIOS_IVT				equ 0x00000000
Mem_BIOS_Data				equ 0x00000400
Mem_Sector_Buffer			equ 0x00000800
Mem_GDT					equ 0x00003000
Mem_TSS64				equ 0x00003100
Mem_Globals				equ 0x00003200
Mem_Stack_Bottom			equ 0x00004000
Mem_Stack_Top				equ 0x00007C00
Mem_Loader1				equ 0x00007C00
Mem_Loader2				equ 0x00008000
Mem_PageTable				equ 0x00010000
Mem_PageTable_PML4T			equ 0x00010000
Mem_PageTable_PDPT			equ 0x00011000
Mem_PageTable_PDT			equ 0x00012000	; Maps first 10 megabytes
Mem_PageTable_PT			equ 0x00013000	; Maps first 2 megabytes
Mem_PageTable_End			equ 0x00020000
Mem_Stack32_Temp_Bottom			equ 0x0006F000
Mem_Stack32_Temp_Top			equ 0x00070000
Mem_Table				equ 0x00070000	; BIOS-derived layout
Mem_Kernel_LoadBuffer			equ 0x00070000
Mem_Kernel_Stack_NMI_Bottom		equ 0x0008A000	; NMI stack
Mem_Kernel_Stack_NMI_Top		equ 0x0008C000
Mem_Kernel_Stack_DF_Bottom		equ 0x0008C000	; Double-fault stack
Mem_Kernel_Stack_DF_Top			equ 0x0008E000
Mem_Kernel_Stack_MC_Bottom		equ 0x0008E000	; Machine-check stack
Mem_Kernel_Stack_MC_Top			equ 0x00090000
Mem_BIOS_EBDA				equ 0x0009E000
Mem_Video				equ 0x000A0000
Mem_Kernel_Stack_Interrupt_Bottom	equ 0x00100000	; PL-change interrupt stack
Mem_Kernel_Stack_Interrupt_Top		equ 0x001FF000
Mem_Kernel_Stack_Bottom			equ 0x00200000	; Main kernel stack
Mem_Kernel_Stack_Top			equ 0x00300000
Mem_Kernel_Image			equ 0x00300000
Mem_Kernel_Code				equ 0x00301000

;; Layout Region Sizes
Mem_BIOS_IVT_Size		equ 0x00000400
Mem_BIOS_Data_Size		equ 0x00000100
Mem_Loader1_Size		equ 0x00000200
Mem_Loader2_Size		equ 0x00008000
Mem_Sector_Buffer_Size		equ 0x00000800
Mem_Table_Size			equ 0x00006000	; Up to 1023 regions
Mem_Kernel_LoadBuffer_Size	equ 0x00010000

;; Real Mode Segment Addresses
Mem_Loader1_Segment	equ Mem_Loader1 >> 4
Mem_Loader2_Segment	equ Mem_Loader2 >> 4

%endif ; __TUXPEN_MEM_ASM__
