#bochs 2.8

#!/bin/sh


echo "Creating disk.img..."
bximage -func=create -hd=10M -q disk.img



echo "Compiling..."
nasm -I include/ -o mbr.bin mbr.asm
nasm -I include/ -o loader.bin loader.asm
nasm -f elf -o kernel/print.o lib/kernel/print.asm


gcc -m32 -c -o kernel/main.o kernel/main.c
ld -m elf_i386 -Ttext 0xc0001500  -e main -o kernel/kernel.bin kernel/print.o kernel/main.o

echo "Writing mbr and loader to disk..."
dd if=./mbr.bin of=./disk.img bs=512 count=1 conv=notrunc
dd if=./loader.bin of=./disk.img bs=512 count=4 seek=2 conv=notrunc
dd if=kernel/kernel.bin of=disk.img bs=512 count=200 seek=9 conv=notrunc

echo "Now start bochs and have fun!"
bochs -f bochsrc 


