nasm -I include/ -o mbr.bin mbr.S

ddrelease64.exe if=.\mbr.bin of=C:\Users\65185\Desktop\github\hd60m.img bs=512 count=1 conv=notrunc

nasm -I include/ -o loader.bin loader.S

ddrelease64.exe if=.\loader.bin of=C:\Users\65185\Desktop\github\hd60m.img bs=512 count=1 seek=2 conv=notrunc


sleep 5000