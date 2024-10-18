;;; Tuxpen BIOS structures ;;;

%ifndef __TUXPEN_BIOS_ASM__
%define __TUXPEN_BIOS_ASM__

;; BIOS Disk Address Packet (DAP)
struc BIOS_DAP
	.Bytes:			resw 1	; Size of DAP (in bytes)
	.ReadSectors:		resw 1	; Number of sectors being read
	.TargetBufferOffset:	resw 1	; Target buffer address offset
	.TargetBufferSegment:	resw 1	; Target buffer address segment
	.FirstSector:		resq 1	; First sector to read
endstruc

%endif ; __TUXPEN_BIOS_ASM__
