; simple_mbr.asm

%include "boot.inc"

bits 16
org 0x7c00

start:
    mov ah, 0x0e
    mov al, 'X'
    int 0x10

jmp LOADER_BASE_ADDR

times 510-($-$$) db 0;
db 0x55
db 0xAA

