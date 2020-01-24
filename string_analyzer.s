; String Analyzer
; Collin McKinley
; Written in ONLY x86 Assembly for your enjoyment
; Commented for your sanity

section .data

    ; Define our messages we will print in the program
    msg: db 'Please enter a string to be analyzed: ', 0
    
    dat_string: db 'String:',9,9, 0
    
    dat_lc: db 'Lowercase:',9, 0
    
    dat_uc: db 'Uppercase:',9, 0
    
    dat_cc: db 'Characters:',9, 0
    

section .bss
    ; Reserve 128 bytes plus one for null termination for the strings
    string_buffer: resb 65
    uc_buffer: resb 65
    lc_buffer: resb 65
    
    ; Reserve 64 bytes for conversion buffer for misc conversions
    conv_buffer: resb 2

section .text
    global _start

; Get the length of the string, for use with printing and later display
_get_len:

    ; Move one byte of the string into ecx, reset edx to zero, this will be our counter
    mov al, [esi]
    xor edx, edx
    mov edx, 0

    ; While ecx is not equal to NULL (0x0)
    .null_loop:
        
        cmp al, 0x0
        ; if NULL then goto done
        je .done

        ; If not, move to next byte and add one to the counter
        inc esi
        mov al, [esi]
        add edx, 1
        
        ; Continue loop
        jmp .null_loop
    .done:
        ; return to call
        ret

; Convert a decimal (edx) to a string (esi), used for the count 
_dec_to_string:
    
    ; Move our conversion buffer into play, also mov edx into eax
    mov esi, conv_buffer
    mov eax, edx
    ; Remove one from eax (do it doesnt count newline in charcount)
    sub eax, 1

    ; Setup division
    mov edx, 0
    mov ecx, 10
    div ecx
    
    ; Add 48 to the remainder so we get an ascii character and move into esi
    add edx, 48
    mov [esi], edx
    inc esi

    cmp eax, 0
    je .done

    ; Now start the loop and continue doing the same thing with one change
    .loop:

        mov edx, 0
        mov ecx, 10
        div ecx
    
        add edx, 48
        
        ; Swap previous characters with new ones, so smaller numbers go to the back

        dec esi
        mov ecx, [esi]
        
        xchg ecx, edx
        
        mov [esi], ecx
        inc esi

        mov [esi], edx
        inc esi

        cmp eax, 0
        je .done
        
        jmp .loop
    .done:
        ; Add a new line and return
        mov ecx, 10
        mov [esi], ecx
        ret

; Convert esi to uppercase and return
_to_uc:
    ; Move one byte of the string into ecx
    mov edi, uc_buffer
    mov al, [esi]

    .uc_loop:
        
        ; If al is NULL, then the string is over
        cmp al, 0
        je .done
        ; If al is less than 97 and above 122, it is not lowercase
        cmp al, 97
        jb .next
        cmp al, 122
        ja .next
        
        ; Remove 32 to make it uppercase
        sub al, 32
        
    .next:
        
        ; Add it to the buffers and increment
        mov [edi], al
        inc edi
        inc esi
        mov al, [esi]
        jmp .uc_loop
    .done:
        ; return to call
        ret
_to_lc:
    ; Move one byte of the string into ecx
    mov edi, lc_buffer
    mov al, [esi]

    .lc_loop:
        
        ; If al is NULL, then the string is over
        cmp al, 0
        je .done
        ; If al is less than 97 and above 122, it is not lowercase
        cmp al, 65
        jb .next
        cmp al, 90
        ja .next
        
        ; Remove 32 to make it uppercase
        add al, 32
        
    .next:
        
        ; Add it to the buffers and increment
        mov [edi], al
        inc edi
        inc esi
        mov al, [esi]
        jmp .lc_loop
    .done:
        ; return to call
        ret


_start:

    ; Print greeting message asking for input
    mov esi, msg
    call _get_len
    mov ecx, msg
    mov ebx, 1
    mov eax, 4
    int 80h

    ; Get our string to analyze

    mov eax, 3
    mov ebx, 0
    mov ecx, string_buffer
    mov edx, 64
    int 80h

    ; Begin to analyze, first by printing it out

        ; Status message
        mov esi, dat_string
        call _get_len
        mov ecx, dat_string
        mov ebx, 1
        mov eax, 4
        int 80h

        ; Print string
        mov esi, string_buffer
        call _get_len
        mov ecx, string_buffer
        mov ebx, 1
        mov eax, 4
        int 80h

    ; Next get length and convert to string for easy viewing (sucks to look at ascii characters then translate them to numbers doesnt it?)

        ; Status message
        mov esi, dat_cc
        call _get_len
        mov ecx, dat_cc
        mov ebx, 1
        mov eax, 4
        int 80h

        ; Print string
        mov esi, string_buffer
        call _get_len

        ; Convert length to a string we can output
        mov esi, conv_buffer
        call _dec_to_string
        

        ; Output it
        mov esi, conv_buffer
        call _get_len

        mov ecx, conv_buffer
        mov ebx, 1
        mov eax, 4
        int 80h
    
    ; Next convert to Uppercase

        ; Status message
        mov esi, dat_uc
        call _get_len
        mov ecx, dat_uc
        mov ebx, 1
        mov eax, 4
        int 80h

        ; Print string
        mov esi, string_buffer    
        call _to_uc
        mov esi, uc_buffer
        call _get_len
        mov ecx, uc_buffer
        mov ebx, 1
        mov eax, 4
        int 80h
    
    ; And finally, convert to Lowercase

        ; Status message
        mov esi, dat_lc
        call _get_len
        mov ecx, dat_lc
        mov ebx, 1
        mov eax, 4
        int 80h

        ; Print string
        mov esi, string_buffer    
        call _to_lc
        mov esi, lc_buffer
        call _get_len
        mov ecx, lc_buffer
        mov ebx, 1
        mov eax, 4
        int 80h
    
    ; Exit the program gracefully
    mov ebx, 0
    mov eax, 1
    int 80h
