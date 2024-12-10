; 主引导程序
;-----------------------------------------------
%include "boot.inc"
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


;显示字符串 "Raymond Lee"
mov di, 0x0000

mov byte [gs:di], 'R'
mov byte [gs:di+1], 0x07  ; 白色前景，黑色背景
add di, 2

mov byte [gs:di], 'a'
mov byte [gs:di+1], 0x07
add di, 2

mov byte [gs:di], 'y'
mov byte [gs:di+1], 0x07
add di, 2

mov byte [gs:di], 'm'
mov byte [gs:di+1], 0x07
add di, 2

mov byte [gs:di], 'o'
mov byte [gs:di+1], 0x07
add di, 2

mov byte [gs:di], 'n'
mov byte [gs:di+1], 0x07
add di, 2

mov byte [gs:di], 'd'
mov byte [gs:di+1], 0x07
add di, 2

mov byte [gs:di], ' '
mov byte [gs:di+1], 0x07
add di, 2

mov byte [gs:di], 'L'
mov byte [gs:di+1], 0x07
add di, 2

mov byte [gs:di], 'e'
mov byte [gs:di+1], 0x07
add di, 2

mov byte [gs:di], 'e'
mov byte [gs:di+1], 0x07
add di, 2

mov eax, LOADER_START_SECTOR
mov bx, LOADER_BASE_ADDR
mov cx, 1
call rd_disk_m_16

jmp LOADER_BASE_ADDR

;-----------------------------------------------------------
; 读取磁盘的n个扇区，用于加载loader
; eax保存从硬盘读取到的数据的保存地址，ebx为起始扇区，cx为读取的扇区数
rd_disk_m_16:
;-----------------------------------------------------------

    mov esi, eax
    mov di, cx

    ;读一个扇区 
    mov dx, 0x1f2
    mov al, 1
    out dx, al

    mov eax, LOADER_START_SECTOR

    ;以LBA方式读取硬盘，分别设置LBA的低中高三部分，对应的端口号分别是0x1f3-0x1f5

    mov dx, 0x1f3
    out dx, al

    shr eax, 8
    mov dx, 0x1f4
    out dx, al

    shr eax, 8
    mov dx, 0x1f5
    out dx, al

    shr eax, 8
    and al, 0x0f; 只保留4位
    or al, 0xe0; 设置驱动器号
    mov dx, 0x1f6
    out dx, al


    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

.not_ready:
    nop;                这是一个空操作指令，通常用于在循环中引入延迟或占位。
    in al, dx;          从端口dx读取一个字节到al。这里dx应该已经被设置为硬盘状态寄存器的端口号（通常是0x1F7）
    and al, 0x88;       对al进行按位与操作，保留al的第4位和第7位。这些位在IDE状态寄存器中通常代表设备忙（BSY）和数据请求（DRQ）状态。
    cmp al, 0x08;       将al与0x08比较，即检查DRQ位是否设置且BSY位未设置
    jnz .not_ready;     如果比较结果不为零（即DRQ未准备好或设备忙），则跳回到.not_ready，继续等待。

    mov ax, di;         将di寄存器的值（通常是扇区数）复制到ax寄存器。
    mov dx, 256;        将常数256加载到dx寄存器中
    mul dx;             每个扇区512字节，每次读一个字的数据=2字节，需要读取的次数就是512*扇区数/2, 也就是现在的256*扇区数。这个计算结果存储在dx:ax，ax存低位，dx存高位
    mov cx, ax;         将ax中的低16位结果复制到cx寄存器中，用于后续的循环传输数据
    mov dx, 0x1f0;      0x1F0加载到dx寄存器中，准备从此端口读取数据

.go_on_read:
    in ax, dx;          从dx指向的端口读16位到ax
    mov [bx], ax;       将ax数据复制到bx指向的地址，在我们的程序中这个值为LOADER_BASE_ADDR=0x900
    add bx, 2;          bx指针移动
    loop .go_on_read;   LOOP指令将CX寄存器的值减1，并检查结果。如果CX不为零，则跳转到标签.go_on_read，继续循环
    ret

times 510-($-$$) db 0
db 0x55, 0xaa