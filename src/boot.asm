[org 0x7C00]			; Set the origin - standard for bootloaders

jmp start			; Jump to start of code

section .text
msg     db  "Hello World!",10	; Our message with a newline
len     equ $ - msg		; Calculate length of message

section .text
start:
	mov	ah, 0x0e	; tty mode

	mov	edx, len	; Calculate message length
	mov	ecx, msg	; Load address of message

print:
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
