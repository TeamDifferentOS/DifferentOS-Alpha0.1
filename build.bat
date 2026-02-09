@echo off
echo Kompiliere DifferentOS...

echo Kompiliere Bootloader...
nasm -f bin boot.asm -o boot.bin
if errorlevel 1 goto error

echo Kompiliere Kernel...
nasm -f bin kernel.asm -o kernel.bin
if errorlevel 1 goto error

echo Erstelle Floppy-Image...
copy /b boot.bin+kernel.bin diffos.img
fsutil file seteof diffos.img 1474560

echo Erstelle ISO-Image...
if exist iso rmdir /s /q iso
mkdir iso
copy diffos.img iso\
mkisofs -o diffos.iso -b diffos.img -no-emul-boot iso

echo.
echo Fertig! diffos.iso wurde erstellt.
echo.
echo Zum Testen mit QEMU:
echo   qemu-system-i386 -cdrom diffos.iso
echo.
goto end

:error
echo.
echo FEHLER beim Kompilieren!
echo Stelle sicher, dass NASM installiert ist.
echo.

:end
pause
