extern _printf


section .text

global _main


_main:
    ; parse sign of arg2
    mov ebx, [esp + 8] ; ebx = argv
    mov eax, [ebx + 8] ; eax = argv[2]
    mov [start_num_arg], eax
    
    mov cl, [eax] ; cl = argv[2][0]

    cmp cl, 45 ; 45 -- code of "-"
    jne not_negative
    ; is negative
    mov cl, 0xFF
    mov [is_negative], cl
    
    ; skip sing in future
    mov ecx, [start_num_arg]
    inc ecx
    mov [start_num_arg], ecx
    
    ; is't negative
not_negative:


    ret
    
    
section .data
is_negative db 0 ; 0 - positive or zero, 0xFF - negative

start_num_arg dd 0 

 
section .rodata
text db "Hello, world", 0