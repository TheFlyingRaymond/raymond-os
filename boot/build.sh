echo "创建硬盘"
bximage -hd -mode='flat' -size=60M -q disk.img 

echo "编译文件"
nasm -I include/ -o mbr.bin mbr.S
ddrelease64 if=./mbr.bin of=./disk.img bs=512 count=1 conv=notrunc

echo "写入磁盘"
nasm -I include/ -o loader.bin loader.S
ddrelease64 if=./loader.bin of=./disk.img bs=512 count=1 seek=2 conv=notrunc

bochs -f bochsrc
