#bochs 2.8

#!/bin/sh

./clear.sh

echo "Creating disk.img..."
bximage -hd -mode=flat -size=60m -q  disk.img



echo "Compiling..."
nasm -I include/ -o mbr.bin mbr.asm

echo "Writing mbr and loader to disk..."
dd if=./mbr.bin of=./disk.img bs=512 count=1 conv=notrunc

echo "Now start bochs and have fun!"
bochs -f bochsrc 


