extern _printf

section .text
global _fdct
global _idct

fdct_helper:
    push ebp
    mov ebp, esp
    push ebx
    
    mov eax, [ebp + 8]
    mov ebx, [ebp + 12]
    mov ecx, [ebp + 16]
    
    movaps xmm0, [eax]
    movaps xmm1, [eax + 4 * 4]
    
    ; 1
    movaps xmm2, [ecx + 0 * 4]
    movaps xmm3, [ecx + 4 * 4]
    dpps xmm2, xmm0, 0xff
    dpps xmm3, xmm1, 0xff
    addss xmm2, xmm3
    movss [ebx + 0 * 8 * 4], xmm2

    ; 2
    movaps xmm2, [ecx + 8 * 4]
    movaps xmm3, [ecx + 12 * 4]
    dpps xmm2, xmm0, 0xff
    dpps xmm3, xmm1, 0xff
    addss xmm2, xmm3
    movss [ebx + 1 * 8 * 4], xmm2

    ; 3
    movaps xmm2, [ecx + 16 * 4]
    movaps xmm3, [ecx + 20 * 4]
    dpps xmm2, xmm0, 0xff
    dpps xmm3, xmm1, 0xff
    addss xmm2, xmm3
    movss [ebx + 2 * 8 * 4], xmm2

    ; 4
    movaps xmm2, [ecx + 24 * 4]
    movaps xmm3, [ecx + 28 * 4]
    dpps xmm2, xmm0, 0xff
    dpps xmm3, xmm1, 0xff
    addss xmm2, xmm3
    movss [ebx + 3 * 8 * 4], xmm2

    ; 5
    movaps xmm2, [ecx + 32 * 4]
    movaps xmm3, [ecx + 36 * 4]
    dpps xmm2, xmm0, 0xff
    dpps xmm3, xmm1, 0xff
    addss xmm2, xmm3
    movss [ebx + 4 * 8 * 4], xmm2

    ; 6
    movaps xmm2, [ecx + 40 * 4]
    movaps xmm3, [ecx + 44 * 4]
    dpps xmm2, xmm0, 0xff
    dpps xmm3, xmm1, 0xff
    addss xmm2, xmm3
    movss [ebx + 5 * 8 * 4], xmm2

    ; 7
    movaps xmm2, [ecx + 48 * 4]
    movaps xmm3, [ecx + 52 * 4]
    dpps xmm2, xmm0, 0xff
    dpps xmm3, xmm1, 0xff
    addss xmm2, xmm3
    movss [ebx + 6 * 8 * 4], xmm2

    ; 8
    movaps xmm2, [ecx + 56 * 4]
    movaps xmm3, [ecx + 60 * 4]
    dpps xmm2, xmm0, 0xff
    dpps xmm3, xmm1, 0xff
    addss xmm2, xmm3
    movss [ebx + 7 * 8 * 4], xmm2

    
    
    pop ebx
    leave
    ret
    
_fdct:
    push ebp
    mov ebp, esp
    push ebx
    ; <<<

    mov eax, [ebp + 8]
    mov ebx, [ebp + 12]
    mov ecx, [ebp + 16]

    push ebp
    
    matrix_loop_f:
        push ecx
        
        ; == loop col ==========================
        mov ebp, 7 * 8 * 4
        mov ecx, 8
        loop_col_f:
            ; call 1D
            push eax
            push ecx
            push edx

            ; coef_f
            mov edx, coef_f
            push edx
            
            ; buffer + ecx
            lea edx, [buffer + ecx * 4 - 4]
            push edx

            ; source + ecx * 8
            lea edx, [eax + ebp]
            push edx
            
            call fdct_helper
            
            add esp, 12

            pop edx
            pop ecx
            pop eax
            
            sub ebp, 8 * 4 
        loop loop_col_f

         ; == loop row ==========================
        mov ebp, 7 * 8 * 4
        mov ecx, 8
        loop_row_f:
            ; call 1D
            push eax
            push ecx
            push edx

            ; coef_f
            mov edx, coef_f
            push edx
            
            ; buffer + ecx
            lea edx, [ebx + ecx * 4 - 4]
            push edx

            ; source + ecx * 8
            lea edx, [buffer + ebp]
            push edx
            
            call fdct_helper
            
            add esp, 12

            pop edx
            pop ecx
            pop eax
            
            sub ebp, 8 * 4 
        loop loop_row_f

        add eax, 64 * 4
        add ebx, 64 * 4

        pop ecx
    loop matrix_loop_f
    
    pop ebp
    
    ; >>>
    pop ebx
    leave
    ret

    
_idct:
    push ebp
    mov ebp, esp
    push ebx
    ; <<<

    mov eax, [ebp + 8]
    mov ebx, [ebp + 12]
    mov ecx, [ebp + 16]

    push ebp
    
    matrix_loop_i:
        push ecx
        
        ; == loop col ==========================
        mov ebp, 7 * 8 * 4
        mov ecx, 8
        loop_col_i:
            ; call 1D
            push eax
            push ecx
            push edx

            ; coef_f
            mov edx, coef_i
            push edx
            
            ; buffer + ecx
            lea edx, [buffer + ecx * 4 - 4]
            push edx

            ; source + ecx * 8
            lea edx, [eax + ebp]
            push edx
            
            call fdct_helper
            
            add esp, 12

            pop edx
            pop ecx
            pop eax
            
            sub ebp, 8 * 4 
        loop loop_col_i

         ; == loop row ==========================
        mov ebp, 7 * 8 * 4
        mov ecx, 8
        loop_row_i:
            ; call 1D
            push eax
            push ecx
            push edx

            ; coef_f
            mov edx, coef_i
            push edx
            
            ; buffer + ecx
            lea edx, [ebx + ecx * 4 - 4]
            push edx

            ; source + ecx * 8
            lea edx, [buffer + ebp]
            push edx
            
            call fdct_helper
            
            add esp, 12

            pop edx
            pop ecx
            pop eax
            
            sub ebp, 8 * 4 
        loop loop_row_i

        add eax, 64 * 4
        add ebx, 64 * 4

        pop ecx
    loop matrix_loop_i
    
    pop ebp
    
    ; >>>
    pop ebx
    leave
    ret
   
section .rodata

printf_format db "%d", 10, 0

; magic coef. Calculate by c++ program.
align 16
coef_f:
    dd 0.125000, 0.125000, 0.125000, 0.125000, 0.125000, 0.125000, 0.125000, 0.125000 
    dd 0.173380, 0.146984, 0.098212, 0.034487, -0.034487, -0.098212, -0.146984, -0.173380 
    dd 0.163320, 0.067650, -0.067650, -0.163320, -0.163320, -0.067649, 0.067650, 0.163320 
    dd 0.146984, -0.034487, -0.173380, -0.098212, 0.098212, 0.173380, 0.034487, -0.146984 
    dd 0.125000, -0.125000, -0.125000, 0.125000, 0.125000, -0.125000, -0.125000, 0.125000 
    dd 0.098212, -0.173380, 0.034487, 0.146984, -0.146984, -0.034487, 0.173380, -0.098212 
    dd 0.067650, -0.163320, 0.163320, -0.067650, -0.067649, 0.163320, -0.163320, 0.067650 
    dd 0.034487, -0.098212, 0.146984, -0.173380, 0.173380, -0.146984, 0.098212, -0.034488
    
    
align 16
coef_i:    
    dd 1.000000, 1.387040, 1.306563, 1.175876, 1.000000, 0.785695, 0.541196, 0.275899 
    dd 1.000000, 1.175876, 0.541196, -0.275899, -1.000000, -1.387040, -1.306563, -0.785695 
    dd 1.000000, 0.785695, -0.541196, -1.387040, -1.000000, 0.275900, 1.306563, 1.175876 
    dd 1.000000, 0.275899, -1.306563, -0.785695, 1.000000, 1.175876, -0.541196, -1.387040 
    dd 1.000000, -0.275899, -1.306563, 0.785695, 1.000000, -1.175876, -0.541196, 1.387040 
    dd 1.000000, -0.785695, -0.541196, 1.387040, -1.000000, -0.275899, 1.306563, -1.175876 
    dd 1.000000, -1.175876, 0.541196, 0.275899, -1.000000, 1.387040, -1.306563, 0.785696 
    dd 1.000000, -1.387040, 1.306563, -1.175876, 1.000000, -0.785695, 0.541197, -0.275900 
    
    
section .data

align 16 
buffer:
    times 64 dd 0
    
