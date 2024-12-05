echo "====================清理数据===================="
./clear.sh

echo "====================创建硬盘===================="
bximage -hd -mode='flat' -size=10M -q disk.img 

echo "====================编译文件===================="
nasm -I include/ -o mbr.bin simple_mbr.asm
ddrelease64 if=./mbr.bin of=./disk.img bs=512 count=1 conv=notrunc

echo "====================启动虚拟机===================="
bochs -f bochsrc

echo "====================清理数据===================="
./clear.sh