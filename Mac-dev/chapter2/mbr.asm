; 主引导程序
;-----------------------------------------------
SECTION MBR vstart=0x7c00

mov ax, cs
mov ds, ax
mov es, ax
mov ss, ax
mov fs, ax
mov sp, 0x7c00
mov ax, 0xb800
mov gs, ax

; 清屏
;---------------------------------------------------
mov ax, 0600h
mov bx, 0700h
mov cx, 0
mov dx, 184fh
int 10h

; 显示"MBR"
mov byte [gs:0x00], '1'
mov byte [gs:0x01], 0xA4

mov byte [gs:0x02], ' '
mov byte [gs:0x03], 0xA4

mov byte [gs:0x04], 'M'
mov byte [gs:0x05], 0xA4

mov byte [gs:0x06], 'B'
mov byte [gs:0x07], 0xA4

mov byte [gs:0x08], 'R'
mov byte [gs:0x09], 0xA4


hang:
    jmp hang       ; 无限循环，停止代码执行·


; 填充剩余字节，使总大小达到512字节
times 510-($-$$) db 0 ; 用0填充到510字节
dw 0xAA55        ; 启动扇区签名（0x55AA）