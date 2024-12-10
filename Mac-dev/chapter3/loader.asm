%include "boot.inc"

section loader vstart=LOADER_BASE_ADDR

;清屏
mov ax, 0600h
mov bx, 0700h
mov cx, 0
mov dx, 184fh
int 10h

;打印字符串
mov di, 0x0000  ; 设置显存起始位置
mov byte [gs:di], 'I'
mov byte [gs:di+1], 0x07  ; 白色前景，黑色背景
add di, 2

mov byte [gs:di], ' '
mov byte [gs:di+1], 0x07
add di, 2

mov byte [gs:di], 'm'
mov byte [gs:di+1], 0x07
add di, 2

mov byte [gs:di], 'i'
mov byte [gs:di+1], 0x07
add di, 2

mov byte [gs:di], 's'
mov byte [gs:di+1], 0x07
add di, 2

mov byte [gs:di], 's'
mov byte [gs:di+1], 0x07
add di, 2

mov byte [gs:di], ' '
mov byte [gs:di+1], 0x07
add di, 2

mov byte [gs:di], 'y'
mov byte [gs:di+1], 0x07
add di, 2

mov byte [gs:di], 'o'
mov byte [gs:di+1], 0x07
add di, 2

mov byte [gs:di], 'u'
mov byte [gs:di+1], 0x07
add di, 2

mov byte [gs:di], ' '
mov byte [gs:di+1], 0x07
add di, 2

mov byte [gs:di], 's'
mov byte [gs:di+1], 0x07
add di, 2

mov byte [gs:di], 'o'
mov byte [gs:di+1], 0x07
add di, 2

mov byte [gs:di], ' '
mov byte [gs:di+1], 0x07
add di, 2

mov byte [gs:di], 'm'
mov byte [gs:di+1], 0x07
add di, 2

mov byte [gs:di], 'u'
mov byte [gs:di+1], 0x07
add di, 2

mov byte [gs:di], 'c'
mov byte [gs:di+1], 0x07
add di, 2

mov byte [gs:di], 'h'
mov byte [gs:di+1], 0x07
add di, 2

jmp $