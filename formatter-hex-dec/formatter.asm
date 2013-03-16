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
    
    
; multiply num in st16 to 16
st16_next:
    push eax
    push ebx
    push ecx

    mov bl, 0 ; carry
    
    mov ecx, 0
st16_next_loop:
    cmp ecx, 10 ; TODO change 10
    je st16_next_loop_end

    xor ax, ax
    mov al, [st16 + ecx]
    
    ; ax = al * 16
    mov bh, 16
    mul bh
    
    ; ax = ax + bl(carry)
    mov bh, 0
    add ax, bx
    
    ; ah = ax / 10
    ; al = ax % 10
    mov bh, 10
    div bh
    
    mov [st16 + ecx], ah
    mov bl, al

    inc ecx    
    jmp st16_next_loop
st16_next_loop_end:

    pop ecx
    pop ebx
    pop eax
    ret

; eax - char* first
; ebx - char* second    
long_add:
    mov ecx, 0
    
long_and_loop:
    cmp ecx, 10 ; TODO change 10
    je long_and_loop_end

    jmp long_and_loop
long_and_loop_end:


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

    ; add zero to number and write in hex_num
    mov ebx, [start_num_arg]
add_zero_loop:
    xor eax, eax
    mov al, [ebx]
    cmp al, 0
    je add_zero_loop_end
    call hex_char_to_byte
    ; push in stack
    push eax
    inc ebx

    jmp add_zero_loop
add_zero_loop_end:

    ; cnt in stack:
    sub ebx, [start_num_arg]
    mov ecx, ebx

    mov ebx, hex_num
move_digit_from_stack_to_hex_num_loop:
    cmp ecx, 0
    je move_digit_from_stack_to_hex_num_loop_end
    pop eax
    mov [ebx], al
    inc ebx
    dec ecx

    jmp move_digit_from_stack_to_hex_num_loop
move_digit_from_stack_to_hex_num_loop_end:
    
    ; number is really negative?
    mov eax, hex_num
    mov al, [eax + 3] ; TODO change to 31
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
    
    
    
    ; mov al, [is_negative]
    ; cmp al, 0xFF
    
    ; je print_negative
; print_positive:
    ; push text_positive
    ; call _printf
    ; add esp, 4
    ; ret
; print_negative:
    ; push text_negative
    ; call _printf
    ; add esp, 4
    
    
    ; hex to dec
    mov eax, st16
    mov al, 1
    mov [st16], al
    
    call st16_next
    nop
    call st16_next
    nop
    call st16_next
    nop
    call st16_next
    nop
    
    
    ret
    
    
section .data
is_negative db 0 ; 0 - positive or zero, 0xFF - negative
hex_num db 0,0,0,0 ; TODO change to 32
start_num_arg dd 0 

st16 times 10 db 0 ; ; TODO change to ~50 (16^32)

 
section .rodata
text db "Hello, world", 0

text_negative db "negative",0
text_positive db "positive",0






