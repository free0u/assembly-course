extern printf

section .text

global main
main:
	push text
	call [printf]
	add esp, 4
	ret

section .rodata
text db "Hello, world", 0
