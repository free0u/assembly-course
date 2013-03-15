extern _printf

section .text

global _main

_main:
    push text
    call _printf
    add esp, 4
    ret
    
section .rodata
text db "Hello, world", 0