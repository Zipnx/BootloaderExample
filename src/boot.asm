
bits 16     ; Sets this as 16 bit code
org 0x7c00  ; Output to 0x7c00, where the bios leaves off
boot:
    call cls        ; clear the screen
    
.loop:
    ; === Read a character ===
    mov ah, 0x10    ; Read character extended (blocking operation)
    int 0x16        ; Keyboard services (resulting character is in AL)
    
    ; === If the read character is q exit ===
    cmp al, 0x71    ; Do the comparison
    je .done        ; Jump to done if equal

    ; === Output the character ===
    mov ah, 0x0A    ; Write character
    mov bh, 0x0     ; Display page number
    mov cx, 0x1     ; Times to write the character
                    ; The character is already in AL from the read before
    int 0x10        ; Video services

    ; === Repeat ===
    jmp .loop
.done:
    
    mov si, str_exit  ; Put the exit message in si
    call print        ; Call the print routine

    jmp halt      ; Once done just halt

cls:
    pusha           ; Not quite necessary, but might as well
    mov ah, 0x0     ; Set video mode
    mov al, 0x03    ; Video mode 80x25 text mode, color
    int 0x10        ; Video services
    popa
    ret

print:
    pusha
    mov ah, 0x0e    ; We are printing out characters
.loop_print:
    lodsb           ; Load a byte into al (also increments si)
    or al, al       ; Check if we have reached the null byte
    jz .done_print  ; then we are done
    int 0x10        ; Display the character to the screen
    jmp .loop_print ; repeat
.done_print:
    popa
    ret

halt:
    cli ; clear interrupt flag
    hlt ; halt execution

str_exit:   
    db "Done.", 0

times 510 - ($-$$) db 0 ; pad remaining 510 bytes with zeroes
dw 0xaa55 ; magic bootloader magic - marks this 512 byte sector bootable!
