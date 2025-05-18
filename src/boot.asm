[org 0x7C00]			; Set the origin - standard for bootloaders

jmp start			; Jump to start of code

section .text
msg     db  "Hello World!",10	; Our message with a newline
len     equ $ - msg		; Calculate length of message

section .text
start:

clearScreen:
	mov	ah, 0x06	; Scroll up window
	mov	al, 0x00	; Clear entire screen
	mov	bh, 0x07	; Attribute for blank spaces
	mov	cx, 0x0000	; Upper-left corner (row=0, col=0)
	mov	dx, 0x184F	; Lower-right corner (row=24, col=79)
	int	0x10		; BIOS interrupt to scroll/clear

	mov	edx, len	; Calculate message length
	mov	ecx, msg	; Load address of message
	
print:
	mov	ah, 0x0e	; tty mode
	mov	al, [ecx]	; Load current character
	int	0x10		; Print character
	inc	ecx		; Move to next character
	dec	edx		; Decrement length
	jnz	print		; If length is not zero, continue printing

	hlt			; Halt the CPU
	jmp 	$		; If the previous failed, start an infinite loop

; Zeros up to byte 510
times 510 - ($ - $$) db 0

; Boot signature at bytes 511-512
dw 0xaa55
