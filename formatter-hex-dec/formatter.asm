extern _printf


section .text

global _main
jmp _main

dump_dec_num:
    push eax
    push ecx

    mov ecx, 45
dump_dec_num_loop:

    mov al, [dec_num + ecx]
    
    cmp al, 0
    jne dump_dec_num_loop_end

    cmp ecx, 0 
    je dump_dec_num_loop_end
    dec ecx
    jmp dump_dec_num_loop
dump_dec_num_loop_end:   


    push ebx


    mov ebx, 0
dump_dec_num_loop2:
    
    mov al, [dec_num + ecx]
    add al, 0x30
    inc ebx
    mov [buffer + ebx], al
    
    cmp ecx, 0
    je dump_dec_num_loop2_end
    dec ecx
    jmp dump_dec_num_loop2
dump_dec_num_loop2_end:

    mov al, 0
    mov [buffer], bl
    inc ebx
    mov [buffer + ebx], al
    pop ebx


    ; summary:
    ; num in buffer
    ; format in vars (have_* and len_format)
    ; sign in is_negative
    push ebx
    push edx
    
    
    mov al, [buffer]
    mov ah, [len_format]
    
    mov bl, 0
    cmp ah, al
    jbe if_calc_aling_end 
if_calc_aling:
    sub ah, al
    mov bl, ah
if_calc_aling_end:

    ; bl - size of aling
    mov cl, 0
    or cl, [have_space]
    or cl, [have_plus]
    or cl, [is_negative]
    and cl, 0x01 ; cl = cl & 0b 0000 0001  ;  0xFF -> 0x01 ; 0x00 -> 0x00
    sub bl, cl
    mov cl, 0xFF
    cmp bl, cl
    jne decrease_aling_end
    mov bl, 0
    jmp decrease_aling_end
    
decrease_aling_end: 

    ; bl - size of align!
    
    ; calc real sign char in bh
    mov bh, 0

calc_char_minus:
    mov al, [is_negative]
    
    mov ah, 0xFF
    cmp al, ah
    jne calc_char_plus

    mov bh, 0x2D ; bh = '-'
    jmp calc_char_end

calc_char_plus:
    mov al, [have_plus]
    mov ah, 0xFF
    cmp al, ah
    jne calc_char_space
    mov bh, 0x2B ; bh = '+'
    jmp calc_char_end

calc_char_space:
    mov al, [have_space]
    mov ah, 0xFF
    cmp al, ah
    jne calc_char_end
    mov bh, 0x20 ; bh = ' '
    
calc_char_end:
   
    ;bl - size of align
    ;bh - ascii code of sign or 0x00 if no sign
   
   
zero_indent:
    mov al, [have_zero]
    mov ah, 0xFF
    cmp ah, al
    jne minus_indent
    
    ; case zero
    
    ; print sign
    mov [buffer_print], bh
    mov bh, 0
    mov [buffer_print + 1], bh
    push buffer_print
    call _printf
    add esp, 4
    
    ; print zeroes
    mov ecx, 0
    mov cl, bl
print_zero_loop:
    cmp ecx, 0
    je print_zero_loop_end
    
    mov al, 0x30 ; al = '0'
    mov [buffer_print], al
    mov al, 0
    mov [buffer_print + 1], al
    
    push ecx
    push buffer_print
    call _printf
    add esp, 4
    pop ecx
    
    dec ecx
    jmp print_zero_loop
print_zero_loop_end:
    
    ; print number
    mov ecx, buffer
    inc ecx
    push ecx
    call _printf
    add esp, 4
    
    jmp end_indent
minus_indent:
    mov al, [have_minus]
    mov ah, 0xFF
    cmp al, ah
    jne no_indent
    
    ; case minus
    
    ; print sign
    mov [buffer_print], bh
    mov bh, 0
    mov [buffer_print + 1], bh
    push buffer_print
    call _printf
    add esp, 4

    ; print number
    
    mov ecx, buffer
    inc ecx
    push ecx
    call _printf
    add esp, 4
    
    ; print spaces
    
    mov ecx, 0
    mov cl, bl
print_spaces_loop:
    cmp cl, 0
    je print_spaces_loop_end
    
    mov al, 0x20 ; al = ' '
    mov [buffer_print], al
    mov al, 0
    mov [buffer_print + 1], al
    
    push ecx
    push buffer_print
    call _printf
    add esp, 4
    pop ecx
    
    dec ecx
    jmp print_spaces_loop
print_spaces_loop_end:
    
    jmp end_indent
no_indent:
   
    ; case no indent
   
    ; print spaces
    mov ecx, 0
    mov cl, bl
print_spaces_loop2:
    cmp cl, 0
    je print_spaces_loop2_end
    
    mov al, 0x20 ; al = ' '
    mov [buffer_print], al
    mov al, 0
    mov [buffer_print + 1], al
    
    push ecx
    push buffer_print
    call _printf
    add esp, 4
    pop ecx
    
    dec ecx
    jmp print_spaces_loop2
print_spaces_loop2_end:
   
    ; print sign
    mov [buffer_print], bh
    mov bh, 0
    mov [buffer_print + 1], bh
    push buffer_print
    call _printf
    add esp, 4

    ; print number
    
    mov ecx, buffer
    inc ecx
    push ecx
    call _printf
    add esp, 4

    
   jmp end_indent
end_indent:
   
    pop edx
    pop ebx
    
    pop ecx
    pop eax
    ret

; ==================================================================


erase_buffer:
    push ecx
    push eax
    mov ecx, 0
    mov al, 0
    
erase_buffer_loop:   
    cmp ecx, 50
    je erase_buffer_loop_end
    
    mov [buffer + ecx], al
    inc ecx

    jmp erase_buffer_loop
erase_buffer_loop_end:   
    
    pop eax
    pop ecx

    ret

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
; dl - multiplier
; esi - input/output adress
mul_long_short:
    push eax
    push ebx
    push ecx

    mov bl, 0 ; carry
    
    mov ecx, 0
mul_long_short_loop:
    cmp ecx, 45
    je mul_long_short_loop_end

    xor ax, ax
    mov al, [esi + ecx]
    
    ; ax = al * multiplier
    mov bh, dl
    mul bh
    
    ; ax = ax + bl(carry)
    mov bh, 0
    add ax, bx
    
    ; ah = ax % 10
    ; al = ax / 10
    mov bh, 10
    div bh
    
    mov [esi + ecx], ah
    mov bl, al

    inc ecx    
    jmp mul_long_short_loop
mul_long_short_loop_end:

    pop ecx
    pop ebx
    pop eax
    ret

; eax - char* first
; ebx - char* second    
; first += second
long_add:
    push ecx
    push edx

    mov ecx, 0
    mov dh, 0 ; carry
    
long_and_loop:
    cmp ecx, 45
    je long_and_loop_end

    ; dl = first[ecx]
    mov dl, [eax + ecx]
    
    ; dl += dh(carry)
    add dl, dh
    
    ; dh = second[ecx]
    mov dh, [ebx + ecx]
    
    ; dl += dh
    add dl, dh
    
    
    push eax
    
    movzx ax, dl ; ax = dl
    
    ; ah = ax % 10
    ; al = ax / 10
    mov dh, 10 ; dh = 10
    div dh
    
    mov dl, al
    mov dh, ah
    
    pop eax
    
    xchg dh, dl
    mov [eax + ecx], dl
    
    inc ecx
    jmp long_and_loop
long_and_loop_end:

    pop edx
    pop ecx
    
    ret

_main:
    ; init
    mov al, 1
    mov [st16], al
    mov al, 1
    mov [ONE], al

    ; parse format ================================================
    ; '+' 0x2B
    ; '-' 0x2D
    ; ' ' 0x20 (space)
    ; '0' 0x30
    mov ebx, [esp + 4] ; cnt of arg
    mov eax, 2
    cmp eax, ebx
    
    mov ebx, [esp + 8] ; ebx = argv
    mov eax, [ebx + 4] ; eax = argv[2]
    je parse_number
    
    
    mov ebx, [esp + 8] ; ebx = argv
    mov eax, [ebx + 4] ; eax = argv[1]
    
    mov ecx, 0
parse_format_loop:
    mov bl, [eax + ecx]
    cmp bl, 0
    je parse_format_loop_end

    cmp bl, 0x2B ; plus
    je if_plus
    cmp bl, 0x2D ; minus
    je if_minus
    cmp bl, 0x20 ; space
    je if_space
    cmp bl, 0x30 ; zero
    je if_zero

    
    ; any symbol
parse_format_len_loop:   
    mov bl, [eax + ecx]
    cmp bl, 0
    je parse_format_loop_end

    sub bl, 0x30

    push eax
        
        mov al, [len_format]
        mov ah, 10
        mul ah
        
        add al, bl
        
        mov [len_format], al

    pop eax
    
    inc ecx
    jmp parse_format_len_loop
    
    
    
if_space:
    mov bl, 0xFF
    mov [have_space], bl
    jmp loop_if_end
    
if_plus:
    mov bl, 0xFF
    mov [have_plus], bl
    jmp loop_if_end
    
if_minus:
    mov bl, 0xFF
    mov [have_minus], bl
    jmp loop_if_end
    
if_zero:
    mov bl, 0xFF
    mov [have_zero], bl
    jmp loop_if_end
    
    
loop_if_end:    
    
    inc ecx
    jmp parse_format_loop
parse_format_loop_end:

    
    ; end parse format ============================================
 

    push ecx
    mov ecx, len_format
    pop ecx
 

    ; parse sign of arg2
    mov ebx, [esp + 8] ; ebx = argv
    mov eax, [ebx + 8] ; eax = argv[2]
    
parse_number:
    
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
    mov al, [eax + 31]
    and al, 0x08 ; cmp al, 0b00001000
    cmp al, 0x08
    
    je if_negative_code
if_positive_code:
    mov al, [is_negative]
    xor al, 0x00
    jmp end_if_negative_positive_code
if_negative_code:
    
    ; invert bits and increment
    
    mov ecx, 0
loop_invert:
    cmp ecx, 32
    je loop_invert_end
    
    mov al, [hex_num + ecx]
    xor al, 0x0F ; xor al, 0b 0000 1111
    mov [hex_num + ecx], al
    
    inc ecx
    jmp loop_invert
loop_invert_end:

    mov eax, hex_num
    mov ebx, ONE
    call long_add
    
    ; calc sign
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
    mov ecx, dec_num
    mov ecx, 0
    
convert_base_loop:
    cmp ecx, 5
    je convert_base_loop_end

    
    ; buffer = st16
    call erase_buffer
    mov eax, buffer
    mov ebx, st16
    call long_add
    
    push edx
    push esi
    
    ; buffer *= hex_num[ecx]
    mov dl, [hex_num + ecx]
    mov esi, buffer
    call mul_long_short
    
    ; st16 *= 16
    mov dl, 16
    mov esi, st16
    call mul_long_short
    
    pop esi
    pop edx
    
    mov eax, dec_num
    mov ebx, buffer
    call long_add
    
    inc ecx
    jmp convert_base_loop
convert_base_loop_end:
   
    call dump_dec_num
   
    ret
    
    
section .data
is_negative db 0 ; 0 - positive or zero, 0xFF - negative
hex_num times 50 db 0
dec_num times 50 db 0
start_num_arg dd 0 

st16 times 50 db 0
ONE times 50 db 0
buffer times 50 db 1
buffer_print times 10 db 1

have_space db 0
have_minus db 0
have_plus db 0
have_zero db 0
len_format db 0

section .rodata
text db "Hello, world", 0

text_negative db "negative",0
text_positive db "positive",0






