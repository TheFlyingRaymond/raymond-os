%include "boot.inc"

section loader vstart=LOADER_BASE_ADDR
LOADER_STACK_TOP equ LOADER_BASE_ADDR

jmp loader_start

; 这里其实就是GDT的起始地址，第一个描述符为空
EMPTY_DESC: dd 0x00000000, 0x00000000
; 代码段描述符，一个dd为4字节，段描述符为8字节，先定义低32位，再定义高32位
CODE_DESC: dd 0x0000FFFF, 0x00CF9800
; 栈段描述符，和数据段共用
DATA_STACK_DESC: dd 0x0000FFFF, 0x00CF9200
; 显卡段，非平坦
VIDEO_DESC: dd 0x80000007, 0x00C0920B

GDT_SIZE equ $ - EMPTY_DESC
GDT_LIMIT equ GDT_SIZE - 1

SELECTOR_CODE equ  0000000000001000b
SELECTOR_DATA equ  0000000000010000b
SELECTOR_VIDEO equ 0000000000011000b

gdt_ptr dw GDT_LIMIT
        dd EMPTY_DESC

loadermsg db '2 loader in real.'

loader_start: 
        ; 调用10h号中断显示字符串
        mov sp, LOADER_BASE_ADDR
        mov bp, loadermsg
        ; 字符串长度
        mov cx, 17
        ; 子功能号以及显示方式
        mov ax, 0x1301
        ; 页号:0, 蓝底粉红字
        mov bx, 0x001f
        mov dx, 0x1800
        int 0x10

        ; 打开A20地址线
        in al, 0x92
        or al, 00000010B
        out 0x92, al

        ; 加载gdt
        lgdt [gdt_ptr]

        ; cr0第0位置1
        mov eax, cr0
        or eax, 0x00000001
        mov cr0, eax

        ; 刷新流水线
        jmp dword SELECTOR_CODE:p_mode_start

[bits 32]
p_mode_start:
    mov ax, SELECTOR_DATA
    mov ds, ax
    mov es, ax
    mov ss, ax

    mov esp, LOADER_STACK_TOP
    mov ax, SELECTOR_VIDEO
    mov gs, ax

    mov byte [gs:160], 'P'
    mov byte [gs:161], 0x1F
    mov byte [gs:162], 'R'
    mov byte [gs:163], 0x1F
    mov byte [gs:164], 'O'
    mov byte [gs:165], 0x1F
    mov byte [gs:166], 'T'
    mov byte [gs:167], 0x1F
    mov byte [gs:168], 'E'
    mov byte [gs:169], 0x1F
    mov byte [gs:170], 'C'
    mov byte [gs:171], 0x1F
    mov byte [gs:172], 'T'
    mov byte [gs:173], 0x1F
    mov byte [gs:174], 'E'
    mov byte [gs:175], 0x1F
    mov byte [gs:176], 'D'
    mov byte [gs:177], 0x1F

    jmp $