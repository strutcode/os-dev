[org 0x7C00]			; Set the origin - standard for bootloaders

jmp start			; Jump to start of code

section .text
hex     db "0123456789ABCDEF"	; Characters to print hex values
err	db "Error!",0x0a,0x0d,0	; Error message with new line
reg	db 0

section .text
start:
	call clearScreen	; Clear the screen
	call loadData		; Load remaining binary to memory
	mov ecx, 0x7C00+512	; Load address of the data area
	jmp printAscii		; Jump to print function
	jmp $

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

loadData:
	mov	ah, 0x00	; Reset disks
	mov	dl, 0x80	; Include hard disks
	int	0x13		; BIOS interrupt to reset disk
	
	mov	ah, 0x02	; BIOS read sectors
	mov	al, 0x01	; Number of sectors to read
	mov	dl, 0x80	; Disk (bit 7) drive (0)
	mov	dh, 0x00	; Head (0)
	mov	ch, 0x00	; Cylinder (0)
	mov	cl, 0x02	; Sector (2)
	mov	bx, 0x7C00+512	; Load address
	int	0x13		; BIOS interrupt to read disk

	jc	onError		; Check for error (carry flag set)
	ret

onError:
	; Move all registers to memory
	mov	[reg + 0x00], eax
	mov	[reg + 0x04], ebx
	mov	[reg + 0x08], ecx
	mov	[reg + 0x0C], edx
	mov	[reg + 0x10], esi
	mov	[reg + 0x14], edi
	mov	[reg + 0x18], esp
	mov	[reg + 0x1C], ebp

	mov	ecx, err	; Load error message
	call	printAscii	; Print error message

	mov 	ecx, reg	; Set the starting address

	printRegister:
	mov 	esi, 0x04	; Set the number of bytes to print
	call	printHex	; Print registers in hex
	
	cmp	ecx, reg + 0x1C	; Check if all registers are printed
	jne	printRegister	; If not, continue printing

	jmp	$		; Infinite loop
	
printAscii:
	mov	ah, 0x0e	; TTY mode
	mov	al, [ecx]	; Load the character
	int	0x10		; Print character
	inc	ecx		; Move to next character
	cmp     BYTE [ecx], 0	; Check if the next byte is zero
	jnz	printAscii	; If not zero, continue printing
	
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
	dec	esi		; Decrement length
	jnz	printHex	; If not zero, continue printing

	mov	al, 0x0a	; New line
	int	0x10		; Print
	mov	al, 0x0d	; Carriage return
	int	0x10		; Print 

	ret

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