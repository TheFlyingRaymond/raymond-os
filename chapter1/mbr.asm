;simple_mbr

bits 16
org 0x7c00

start:
    ;利用10中断打印
    mov ah, 0x0e
    mov al, 'X'
    int 0x10
  

;死循环阻止程序退出
hang:
    jmp hang;

;字节填充
times 510 - ($-$$) db 0;

;魔数（扇区签名）
dw 0xAA55;