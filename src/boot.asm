[org 0x7C00]			; Set the origin - standard for bootloaders

jmp start			; Jump to start of code

section .text
hex     db  "0123456789ABCDEF"	; Characters to print hex values

section .text
start:
	mov esp, 0x7C00 + 512	; Set a reasonable stack pointer
	call clearScreen	; Clear the screen
	mov ecx, msg2		; Load address of the data area
	jmp printHex		; Jump to print function

clearScreen:
	mov	ah, 0x06	; Scroll up window
	mov	al, 0x00	; Clear entire screen
	mov	bh, 0x07	; Attribute for blank spaces
	mov	cx, 0x0000	; Upper-left corner (row=0, col=0)
	mov	dx, 0x184F	; Lower-right corner (row=24, col=79)
	int	0x10		; BIOS interrupt to scroll/clear
	mov	ah, 0x02	; Set cursor position
	mov	bh, 0x00	; Page number
	mov	dh, 0x00	; Row (0)
	mov	dl, 0x00	; Column (0)
	int	0x10		; BIOS interrupt to set cursor position
	ret
	
printHex:
	mov	ah, 0x0e	; tty mode
	mov	edx, [ecx]	; Load current value

	ror	edx, 4		; Rotate right to get the high nibble
	call	printHexChar	; Print high nibble as 0-F
	
	rol 	edx, 4		; Rotate left to get the low nibble
	call	printHexChar	; Print low nibble as 0-F

	mov	al, ' '		; Add a space between characters
	int	0x10		; Print character

	inc	ecx		; Move to next byte
	cmp     BYTE [ecx], 0	; Check if the next byte is zero
	jnz	printHex	; If not zero, continue printing

	hlt			; Halt the CPU
	jmp 	$		; If anything causes a wake, start an infinite loop

printHexChar:
	mov	ebx, edx	; Copy the entire value
	and	ebx, 0x0F	; Mask to get the low nibble
	add 	ebx, hex	; Add offset to get the character
	mov	al, [ebx]	; Load the character for the low nibble
	int	0x10		; Print character
	ret

; Zeros up to byte 510
times 510 - ($ - $$) db 0

; Boot signature at bytes 511-512
dw 0xaa55

section .text
msg2 db "Bootloader loaded successfully!", 0x0a, 0x0d