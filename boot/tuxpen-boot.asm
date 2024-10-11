;;; Tuxpen first-stage bootloader ;;;

[BITS 16]	; The first-stage bootloader starts in real mode
[ORG 0]		; Using 0 as the origin allows all code addresses to be offset from 0x7C00

;; Entry point of first-stage bootloader
boot:
	; Start by clearing the screen
	mov ah, 0x00	; AH=0x00/INT 0x10 - Set video mode
	mov al, 0x03	; AL=0x03/INT 0x10 - 80x25 16-color text
	int 0x10	; BIOS video interrupt

	jmp 0x07C0:boot_init	; Update the code segment (CS) to 0x07C0

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
	mov sp, 0x00300000

	mov es, ax	; ES being 0 allows absolute addressing of the first 64K of memory

	sti	; Re-enable interrupts

	mov si, tmp_welcome_msg		; Move temporary welcome message into SI
	call boot_puts			; Print the string

	jmp $	; Infinite loop

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
tmp_welcome_msg:
	db "Welcome to the Tuxpen bootloader!",0

;; End point of first-stage bootloader
boot_end:
	times 510-($-$$) db 0	; Pad out 0s until 510th byte
	dw 0xAA55		; Boot signature
