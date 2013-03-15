extern _printf

section .text

global _main

_main:
        mov ebx, esp
        add ebx, 4

        mov ebx, [ebx]
       
        mov     ebx, [esp + 4]
        
        mov     ebx, [esp + 8]
 
        mov     eax, [ebx]
        push    eax
        call    _printf
        
        mov     eax, [ebx + 4]
        push    eax
        call    _printf
        
        mov     eax, [ebx + 8]
        push    eax
        call    _printf
        
        
    add esp, 12
    ret
    
section .rodata
text db "Hello, world", 0