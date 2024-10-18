;;; Tuxpen first-stage bootloader ;;;

[BITS 16]	; The first-stage bootloader starts in real mode
[ORG 0]		; Using 0 as the origin allows all code addresses to be offset from 0x7C00

;; Includes
%include "boot/mem.asm"
%include "boot/globals.asm"
%include "boot/bios.asm"
%include "boot/iso9660.asm"

;; Entry point of first-stage bootloader
boot:
	; Start by clearing the screen
	mov ah, 0x00	; AH=0x00/INT 0x10 - Set video mode
	mov al, 0x03	; AL=0x03/INT 0x10 - 80x25 16-color text
	int 0x10	; BIOS video interrupt

	jmp Mem_Loader1_Segment:boot_init	; Update the code segment (CS) to 0x07C0

;; Initialize segment and stack registers
boot_init:
	cli	; Clear interrupts

	; Initialize all data segments (except ES) using CS
	mov ax, cs
	mov ds, ax
	mov fs, ax
	mov gs, ax

	; Set up a temporary stack
	xor ax, ax
	mov ss, ax
	mov sp, Mem_Stack_Top

	mov es, ax	; ES being 0 allows absolute addressing of the first 64K of memory

	sti	; Re-enable interrupts

	mov si, tux_boot_start_msg		; Move temporary welcome message into SI
	call boot_puts				; Print the string

	mov byte [es:Globals.DriveNumber], dl	; Store the BIOS boot drive number as a global variable

	;; Locate the ISO9660 sector which contains the root directory
	.boot_find_root_directory:
		;; Scan 2 kilobytes of sectors for the primary volume descriptor
		mov bx, 0x10			; Start at sector 0x10
		mov cx, 1			; Read one sector at a time
		mov di, Mem_Sector_Buffer	; Read into the sector buffer

		.boot_read_volume:
			;; Read the sector which contains the volume descriptor
			call boot_read_sectors
			jc .error
			
			;; The first byte of the volume contains its type
			mov al, [es:Mem_Sector_Buffer]
			
			;; Type 1 is the primary volume descriptor
			cmp al, 0x01
			je .found
			
			;; Type 0xFF is the volume list terminator
			cmp al, 0xFF
			je .error
			
			;; Move on to the next sector
			inc bx
			jmp .boot_read_volume
		
		.found:
			;; The primary volume descriptor contains a root director entry which specifies the sector containing the root directory
			mov bx, [es:Mem_Sector_Buffer + ISO_PrimaryVolumeDescriptor.RootDirEntry + ISO_DirectoryEntry.LocationLBA]
			
			;; Store the root directory sector
			mov [es:Globals.RootDirectorySector], bx
	
	;; Scan the root directory for the second-stage bootloader
	.boot_find_loader:
		.process_sector:
			;; Load the current directory sector into the buffer
			mov cx, 1
			mov di, Mem_Sector_Buffer
			
			call boot_read_sectors
			jc .error
		
		.process_dir_entry:
			;; Check if we ran out of files in the directory
			xor ax, ax
			mov al, [es:di + ISO_DirectoryEntry.RecordLength]
			cmp al, 0
			je .error
			
			;; Check if the entry is a file
			test byte [es:di + ISO_DirectoryEntry.NameLength], loader_filename_length
			jne .next_dir_entry
			
			;; Check if the filename is "LOADER.SYS;1"
			push di
			mov cx, loader_filename_length
			mov si, loader_filename
			add di, ISO_DirectoryEntry.Name
			cld
			rep cmpsb
			pop di
			je .loader_found
		
		.next_dir_entry:
			;; Advance to the next directory entry
			add di, ax
			cmp di, Mem_Sector_Buffer + Mem_Sector_Buffer_Size
			jb .process_dir_entry
		
		.next_sector:
			;; Advance to the next directory sector
			inc bx
			jmp .process_sector
		
		.loader_found:
			;; Display status message
			mov si, tux_boot_loader_found_msg
			call boot_puts

	;; Read second-stage bootloader from disk
	.boot_read_loader:
		;; Get starting sector of second-stage bootloader
		mov bx, [es:di + ISO_DirectoryEntry.LocationLBA]
		
		.calc_size:
			;; Check if the loader is too large (>64KB)
			mov cx, [es:di + ISO_DirectoryEntry.Size + 2]
			cmp cx, 0
			jne .error
			
			;; Read the lower word for the size
			mov cx, [es:di + ISO_DirectoryEntry.Size]
			
			;; Max size is 32KB
			cmp cx, 0x8000
			ja .error
			
			;; Divide loader size by 2KB to get size in sectors
			add cx, Mem_Sector_Buffer_Size - 1
			shr cx, 11
		
		.load:
			;; Initialize es:di with loader target address
			mov ax, Mem_Loader2_Segment
			mov es, ax
			xor di, di
			
			;; Read second-stage bootloader into memory
			call boot_read_sectors
			jc .error

	;; Launch second-stage bootloader
	.boot_launch_loader:
		;; Display status message
		mov si, tux_boot_launching_loader_msg
		call boot_puts
		
		;; Far jump to second-stage bootloader
		jmp 0x0000:Mem_Loader2

	;; Error handling
	.error:
		;; Display error message
		mov si, tux_boot_loader_fail_msg
		call boot_puts
		
		.hang:
			;; Hang the system
			cli
			hlt
			jmp .hang

;; Read one or more 2048-byte sectors from the CDROM
boot_read_sectors:
	;; Fill DAP Buffer
	mov word [BIOS_DAP_Buffer + BIOS_DAP.ReadSectors], cx
	mov word [BIOS_DAP_Buffer + BIOS_DAP.TargetBufferOffset], di
	mov word [BIOS_DAP_Buffer + BIOS_DAP.TargetBufferSegment], es
	mov word [BIOS_DAP_Buffer + BIOS_DAP.FirstSector], bx

	;; Load ds:si with DAP buffer address
	lea si, [BIOS_DAP_Buffer]

	;; Call int 0x13 function 0x42
	mov ax, 0x4200
	int 0x13
	ret

;; Displays a null-terminated string to the console
boot_puts:
	pusha	; Push the flags to the stack

	mov ah, 0x0E	; AH=0x0E/INT 0x10 - BIOS teletype output
	xor bx, bx	; Zero out bx since we do not care about the page number or foreground pixel color

	cld

	.loop:
		lodsb	; Load next character in string into AL
		
		; Check if we have reached the end of the string and break if so
		cmp al, 0
		je .done
		
		int 0x10	; Call INT 0x10 to print the character currently stored in AL
		jmp .loop	; Loop to next character

	.done:
		popa	; Pop the flags off the stack
		ret

;; GLOBAL VARIABLES
tux_boot_start_msg:
	db "[TUX] First-stage bootloader started",0xA,0xD,0
loader_filename:
	db "LOADER.SYS;1"

loader_filename_length equ ($ - loader_filename)

tux_boot_loader_found_msg:
	db "[TUX] Second-stage bootloader found",0xA,0xD,0
tux_boot_launching_loader_msg:
	db "[TUX] Launching second-stage bootloader",0xA,0xD,0
tux_boot_loader_fail_msg:
	db "[TUX] Failed to load second-stage bootloader",0xA,0xD,0x0

BIOS.DAP_size:
	db 16

align 4
BIOS_DAP_Buffer:
	istruc BIOS_DAP
		at BIOS_DAP.Bytes, db BIOS.DAP_size
		at BIOS_DAP.ReadSectors, dw 0
		at BIOS_DAP.TargetBufferOffset, dw 0
		at BIOS_DAP.TargetBufferSegment, dw 0
		at BIOS_DAP.FirstSector, dq 0
	iend

;; End point of first-stage bootloader
boot_end:
	times 510-($-$$) db 0	; Pad out 0s until 510th byte
	dw 0xAA55		; Boot signature
