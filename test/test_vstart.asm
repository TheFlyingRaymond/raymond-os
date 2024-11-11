section code vstart=0x7c00
mov ax, $$
mov ax, section.data.start
mov ax, [var1]
mov ax, [var2]
label: jmp label

section data vstart=0x9c00
var1 dd 0x4
var2 dw 0x99