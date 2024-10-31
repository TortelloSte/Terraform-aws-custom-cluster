[org 0x7c00]          ; Indica che il codice verrà caricato all'indirizzo 0x7c00 in memoria

start:
    mov ah, 0x0E
    mov al, 'H'
    int 0x10           ; Stampa 'H' sullo schermo
    mov al, 'i'
    int 0x10           ; Stampa 'i' sullo schermo

    jmp $              ; Blocca l'esecuzione qui (loop infinito)

times 510-($-$$) db 0  ; Riempi fino a 512 byte
dw 0xAA55              ; Firma necessaria per i bootloader
