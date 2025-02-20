#bochs 2.8

#!/bin/sh
./clear.sh

echo "Creating disk.img..."
bximage -func=create -hd=60M  -q  disk.img

echo "Compiling..."
nasm -I include/ -o mbr.bin mbr.asm
nasm -I include/ -o loader.bin loader.asm

echo "Writing mbr and loader to disk..."
dd if=./mbr.bin of=./disk.img bs=512 count=1 conv=notrunc
dd if=./loader.bin of=./disk.img bs=512 count=4 seek=2 conv=notrunc

echo "Now start bochs and have fun!"
bochs -f bochsrc 
