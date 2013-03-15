extern _printf


section .text

global _main
jmp _main

; input al
; output al
hex_char_to_byte:
    or al, 0x20
    
    cmp al, 0x61 ; 'a' == 0x61
    jb if_is_digit ; al < 'a' then digit else letter
if_is_letter:
    sub al, 0x61 ; al -= 'a'
    add al, 10 ; al += 10
    ret
if_is_digit:
    sub al, 0x30 ; al -= '0'
    ret
    

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



    ; number is really negative?
    ; TODO think about length
    mov eax, [start_num_arg]
    mov al, [eax]
    call hex_char_to_byte
    and al, 0x0A ; cmp al, 0b1000
    cmp al, 0x0A
    
    je if_negative_code
if_positive_code:
    mov al, [is_negative]
    
    jmp end_if_negative_positive_code
if_negative_code:
    mov al, [is_negative]
    xor al, 0xFF
end_if_negative_positive_code:    
    mov [is_negative], al
    
    
    
    mov al, [is_negative]
    cmp al, 0xFF
    
    je print_negative
print_positive:
    push text_positive
    call _printf
    add esp, 4
    ret
print_negative:
    push text_negative
    call _printf
    add esp, 4
    
    
    ret
    
    
section .data
is_negative db 0 ; 0 - positive or zero, 0xFF - negative

start_num_arg dd 0 

 
section .rodata
text db "Hello, world", 0

text_negative db "negative",0
text_positive db "positive",0






