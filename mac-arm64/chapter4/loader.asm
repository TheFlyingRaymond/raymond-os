%include "boot.inc"
section loader vstart=0x900
LOADER_STACK_TOP equ 0x900

jmp loader_start

; 这里其实就是GDT的起始地址，第一个描述符为空
GDT_BASE: dd 0x00000000, 0x00000000
; 代码段描述符，一个dd为4字节，段描述符为8字节，先定义低32位，再定义高32位
CODE_DESC: dd 0x0000FFFF, 0x00CF9800
; 栈段描述符，和数据段共用
DATA_STACK_DESC: dd 0x0000FFFF, 0x00CF9200
; 显卡段，非平坦
VIDEO_DESC: dd 0x80000007, 0x00C0920B

GDT_SIZE equ $ - GDT_BASE
GDT_LIMIT equ GDT_SIZE - 1

SELECTOR_CODE equ  0000000000001000b
SELECTOR_DATA equ  0000000000010000b
SELECTOR_VIDEO equ 0000000000011000b

gdt_ptr dw GDT_LIMIT
        dd GDT_BASE

ards_buf times 244 db 0
ards_nr dw 0

loader_start: 
    ; 开始进入保护模式
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
    ;设置各个段寄存器（段选择子）
    mov ax, SELECTOR_DATA
    mov ds, ax
    mov es, ax
    mov ss, ax

    ;初始化栈指针
    mov esp, LOADER_STACK_TOP

    ;设置视频段的选择子，方便后面打印使用
    mov ax, SELECTOR_VIDEO
    mov gs, ax
    
    call setup_page

    ; 保存gdt表内容到gdt_ptr
    sgdt [gdt_ptr]

    ; 重新设置gdt描述符， 使虚拟地址指向内核的第一个页表
    mov ebx, [gdt_ptr + 2]                  ;gdt_ptr是2B+4B的结构，后4B代表地址，这里是取到地址
    add dword [gdt_ptr + 2], 0xc0000000     ;gdt表地址偏移3GB
    or dword [ebx + 0x18 + 4], 0xc0000000   ;显存段的地址特殊处理一下
    
    add esp, 0xc0000000

    ; 页目录基地址寄存器
    mov eax, PAGE_DIR_TABLE_POS
    mov cr3, eax

    ; 打开分页
    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax

    lgdt [gdt_ptr]

    mov byte [gs:160], 'P'
    mov byte [gs:162], 'A'
    mov byte [gs:164], 'G'
    mov byte [gs:166], 'E'

    jmp $

; 创建页目录以及页表
setup_page:
    ; 页目录表占据4KB空间，清零之
    mov ecx, 4096
    mov esi, 0
.clear_page_dir:   
    mov byte [PAGE_DIR_TABLE_POS + esi], 0
    inc esi
    loop .clear_page_dir

; 创建页目录表(PDE)
.create_pde:
    mov eax, PAGE_DIR_TABLE_POS
    ; 0x1000为4KB，加上页目录表起始地址便是第一个页表的地址
    add eax, 0x1000
    mov ebx, eax

    ; 设置页目录项属性
    or eax, PG_US_U | PG_RW_W | PG_P
    ; 设置第一个页目录项
    mov [PAGE_DIR_TABLE_POS], eax
    ; 第768(内核空间的第一个)个页目录项，与第一个相同，这样第一个和768个都指向低端4MB空间
    mov [PAGE_DIR_TABLE_POS + 0xc00], eax
    ; 最后一个表项指向自己，用于访问页目录本身
    sub eax, 0x1000
    mov [PAGE_DIR_TABLE_POS + 4092], eax

; 创建页表
    mov ecx, 1024
    mov esi, 0
    mov edx, PG_US_U | PG_RW_W | PG_P
.create_pte:
    mov [ebx + esi * 4], edx
    add edx, 4096
    inc esi
    loop .create_pte
    ret
