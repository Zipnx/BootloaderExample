
; BIOS Interrupt list: https://www.liquisearch.com/bios_interrupt_call/interrupt_table

bits 16     ; Sets this as 16 bit code
org 0x7c00  ; Output to 0x7c00, where the bios leaves off
boot:
    call cls        ; clear the screen
    
.loop:
    ; === Read a character ===
    mov ah, 0x10    ; Read character extended (blocking operation)
    int 0x16        ; Keyboard services (resulting character is in AL)
    
    ; === If the read character is q exit ===

    ; === Output the character ===
    mov ah, 0x0A    ; Write character
    mov bh, 0x0     ; Display page number
    mov cx, 0x1     ; Times to write the character
                    ; The character is already in AL from the read before
    int 0x10        ; Video services

    ; === Repeat ===
    jmp .loop

    jmp halt      ; Once done just halt

cls:
    pusha
    mov ah, 0x0
    mov al, 0x03
    int 0x10
    popa
    ret

halt:
    cli ; clear interrupt flag
    hlt ; halt execution

times 510 - ($-$$) db 0 ; pad remaining 510 bytes with zeroes
dw 0xaa55 ; magic bootloader magic - marks this 512 byte sector bootable!
