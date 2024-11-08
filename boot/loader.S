%include "boot.inc"
section loader vstart = LOADER_BASE_ADDR
LOADER_STACK_TOP equ LOADER_BASE_ADDR
jmp loader_start

;构建GDT及其内部描述符
GDT_BASE:   dd 0x00000000
            dd 0x00000000

CODE_DESC:  dd 0x0000FFFF
            dd DESC_CODE_HIGH4

VIDEO_DESC: dd 0x0000007
            dd DESC_VIDEO_HIGH4

GDT_SIZE equ $ - GDT_BASE

GDT_LIMIT equ GDT_SIZE - 1
times 60 dq 0

SELECTOR_CODE  equ (0X0001 << 3) + TI_GDT + RPL0
SELECTOR_DATA  equ (0X0002 << 3) + TI_GDT + RPL0
SELECTOR_VIDEO equ (0X0003 << 3) + TI_GDT + RPL0

;以下是GDT指针，前两个字节是GDT界限，后4个字节是gdt起始地址
gdt_ptr dw GDT_LIMIT
        dd GDT_BASE
loadermsg db '2 loader in real.'

loader_start:
    mov sp, LOADER_BASE_ADDR
    mov bp, loadermsg
    mov cx, 17
    mov ax, 0x1301
    mov bx, 0x001f
    mov dx, 0x1800
    int 0x10

;准备进入保护模式

;进入保护模式步骤一 : 打开A20
in al, 0x92
or al, 0000_0010b
out 0x92, al

;进入保护模式步骤二 : 加载GDT
lgdt [gdt_ptr]

;进入保护模式步骤三 : CR0第0位设置为
mov eax, cr0
or  eax, 00000001
mov cr0, eax

;刷新流水线
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

    jmp $