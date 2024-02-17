
bits 16     ; Sets this as 16 bit code
org 0x7c00  ; Output to 0x7c00, where the bios leaves off
boot:
    call cls        ; clear the screen
    
    .loop:
    ; === Read a character ===
    mov ah, 0x10    ; Read character extended (blocking operation)
    int 0x16        ; Keyboard services (resulting character is in AL)
    
    ; === If the read character is ESC exit ===
    cmp al, 0x1b    ; Do the comparison
    je .done        ; Jump to done if equal

    ; === Check for enter ===

    cmp al, 0x0D    ; Compare with keycode for carriage return
    jne .nextcheck1 ; If not, go to the next check
    mov ah, 0x3     ; Read the cursor position
    xor bh, bh      ; On page 0
    int 0x10        ; execute

    inc dh          ; Increase dh, where the current cursor line is
    xor dl, dl      ; Zero the column since we start from the start of the line
    mov ah, 0x2     ; Need to write the cursor information back
    xor bh, bh      ; Again page 0
    int 0x10
    jmp .loop       ; Loop, character output and other stuff is unnecessary

    .nextcheck1:

    ; === Check for backspace ===

    cmp al, 0x08    ; Check for keycode of backspace
    jne .nextcheck2 ; Same, as before, jump to the next check if not
    
    mov ah, 0x03    ; Read the cursor position
    xor bh, bh
    int 0x10
    
    dec dl          ; Move the cursor back
    
    mov ah, 0x2     ; Write the new cursor pos
    xor bh, bh
    int 0x10
    
    mov ah, 0x0A    ; Just output out a space to delete the previous character
    mov al, 0x20
    xor bh, bh
    mov cx, 0x1
    int 0x10
    
    jmp .loop

    .nextcheck2:
    
    ; === Check for TAB ===
    cmp al, 0x9     ; Check for tab character
    jne .nextcheck3

    mov ah, 0x0A    ; Output 4 spaces
    mov al, 0x20
    xor bh, bh
    mov cx, 0x4     ; Specify 4 times
    int 0x10

    mov ah, 0x03    ; Read the cursor position
    xor bh, bh
    int 0x10

    add dl, 4       ; And increment it by 4

    mov ah, 0x2     ; Write the cursor back
    xor bh, bh
    int 0x10

    .nextcheck3:
    ; === Output the character ===
    mov ah, 0x0A    ; Write character
    mov bh, 0x0     ; Display page number
    mov cx, 0x1     ; Times to write the character
                    ; The character is already in AL from the read before
    int 0x10        ; Video services 

    ; === Move the cursor ===
    mov ah, 0x3      ; Read cursor position
    xor bh, bh      ; Display page number
    int 0x10        ; Video Services, screen line & column will be in bx (high & low)

    inc dl         ; Increase the column by one (nevermind)

    mov ah, 0x2     ; Write cursor position
    xor bh, bh      ; Display page num
    int 0x10        ; bx register set from the previous read

    

    ; === Repeat ===
    jmp .loop
    .done:
    
    mov si, str_exit  ; Put the exit message in si
    call print        ; Call the print routine

    jmp halt      ; Once done just halt

cls:
    pusha           ; Not quite necessary, but might as well
    xor ah, ah      ; Set video mode
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
