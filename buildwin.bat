
echo Build script for Windows
echo.

echo Assembling bootloader...
cd sources\bootloader
nasm -O0 -f bin -o boot.bin bootloader.asm
cd ..

echo Assembling kernel...
nasm -O0 -f bin -o kernel.bin kernel.asm
cd ..

echo Copying kernel and applications to disk image...
copy sources\kernel.bin a:\


echo Done!
