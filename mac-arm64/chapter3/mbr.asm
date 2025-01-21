; 主引导程序
;-----------------------------------------------
%include "boot.inc"
SECTION MBR vstart=0x7c00
init:
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov sp, 0x7c00
    mov ax, 0xb800
    mov gs, ax

clean:
    mov ax, 0600h
    mov bx, 0700h
    mov cx, 0
    mov dx, 184fh
    int 10h

    ; 显示"MBR"
    mov byte [gs:0x00], 'M'
    mov byte [gs:0x01], 0xA4
    mov byte [gs:0x02], 'B'
    mov byte [gs:0x03], 0xA4
    mov byte [gs:0x04], 'R'
    mov byte [gs:0x05], 0xA4

main:
    mov eax, LOADER_START_SECTOR            ;eax中存放要读取的扇区号，即Loader所在的第二扇区
    mov bx, LOADER_BASE_ADDR                ;bx中存放Loader需要加载到的地址，即0x900
    mov cx, 1                               ;cx中存放的是要读取的扇区数，如前文所述，读1扇区就能把Loader加载完毕
    call rd_disk_m_16                       ;加载Loader
    jmp LOADER_BASE_ADDR                    ;跳到0x900开始执行Loader


rd_disk_m_16:                           ;eax中需要写入读到数据后写到内存的地址
    mov esi, eax
    mov di, cx
                                     
    mov dx, 0x1f2                       ;将读取的扇区数同步到响应寄存器。
                                        ;primary通道相关的寄存器都是0x1f?, secondary通道相关的则是0x17?，这里我们选择主通道
    
    mov al, cl                          ;这里其实是想把“读取扇区数”写入到硬盘控制器的0x1f2端口，
                                        ;但是这个数据规定了必须是从al中读取后才能执行后续写操作，所以这里需要把“读取扇区数”写入al
    
    out dx, al                          ;将al中的值写入到硬盘控制器的端口，端口号从dx中获取

    ;=======================================
    ;LBA扇区号，接下来会以LBA28方式读取扇区数据
    ;LBA28读取数据时：
    ; 1. 首先需要分三次把低24位地址分别写入到三个硬盘控制器端口
    ; 2. 将剩余4位地址配合对应的控制信息，写入到device控制器
    ;=======================================

    mov eax, esi
    
    mov dx, 0x1f3                       ;取低8位写入0x1f3即LBA Low
    out dx, al
    
    shr eax, 8                          ;右移8位，此时的低8位代表的是完整地址中的中8为，写入LBA Mid
    mov dx, 0x1f4
    out dx, al
    
    shr eax, 8                          ;与之前相同的逻辑，数据写入LBA Heigh
    mov dx, 0x1f5
    out dx, al

    ;=======================================
    ;最后组装device寄存器数据。device寄存器结构：
    ; 1. 低四位是LBA地址的24-27位
    ; 2. 第4位0代表master盘，1代表slave盘
    ; 3. 第6位1代表LBA方式，0代表CHS方式
    ; 4. 第5位和第7位固定为1
    ;=======================================

    shr eax, 8
    and al, 0x0f; 只保留4位
    or al, 0xe0; 设置驱动器号
    mov dx, 0x1f6
    out dx, al

    ;发出读指令
    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

    ; 等待硬盘准备好数据
.wait:
    nop
    ;检查数据状态时，status寄存器端口仍然是0x1f7，
    ;所谓检查数据状态，就是轮询读取寄存器数据检查状态位
    in al, dx
    and al, 0x88
    cmp al, 0x08
    jnz .wait

    ; 将数据从硬盘缓冲区读取到内存
    ;cx是循环计数，256会指定后面的loop执行256次
    ;为什么是256呢？我们读512字节的数据，读命令每次读一个字=2字节，所有就是256次
    mov cx, 256
    mov dx, 0x1f0

.read:
    in ax, dx                           ;从dx指定的端口，即之前设置的0x1f0读一个字的数据到ax中                        
    mov [bx], ax                        ;将ax中数据写入bx指向的地址中，bx中的地址应为我们loader需要放置的地址
    add bx, 2                           ;地址+2，因为写了2字节的数据
    loop .read                          ;循环一次cx会自动减一，直到cx为0
    ret

times 510-($-$$) db 0
dw 0xAA55;