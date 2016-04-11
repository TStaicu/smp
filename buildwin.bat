
echo Build script for Windows
echo.

echo Assembling bootloader...
cd sources\bootloader
nasm -O0 -f bin -o bootloader.bin bootloader.asm
cd ..

echo Assembling kernel...
nasm -O0 -f bin -o kernel.bin kernel.asm
cd ..

echo Copying kernel and applications to disk image...
copy sources\kernel.bin b:\

echo Adding bootsector to disk image...
cd disk_images
partcopy ..\sources\bootloader\bootloader.bin 0 200 -f0
cd ..




echo Dismounting disk image...
imdisk -D -m B:

echo Done!
