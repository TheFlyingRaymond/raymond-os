# bochs 2.8版本

#!/bin/sh
echo "清理数据..."
./clear.sh

echo "---------Step1: 创建disk.img---------"
bximage -func=create -hd=10M -q disk.img

echo "---------Step2: 编译中---------"
nasm -I include/ -o mbr.bin mbr.asm
nasm -I include/ -o loader.bin loader.asm

echo "---------Step3: 写入磁盘---------"
dd if=mbr.bin of=disk.img bs=512 count=1 conv=notrunc
dd if=loader.bin of=disk.img bs=512 count=4 seek=2 conv=notrunc

echo "---------Step4: 虚拟机启动---------"
bochs -f bochsrc 

echo "---------Step5: 清理数据---------"
./clear.sh