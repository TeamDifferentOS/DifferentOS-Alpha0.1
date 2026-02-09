#!/bin/bash

echo "Kompiliere DifferentOS..."

echo "Kompiliere Bootloader..."
nasm -f bin boot.asm -o boot.bin
if [ $? -ne 0 ]; then
    echo "FEHLER beim Kompilieren des Bootloaders!"
    exit 1
fi

echo "Kompiliere Kernel..."
nasm -f bin kernel.asm -o kernel.bin
if [ $? -ne 0 ]; then
    echo "FEHLER beim Kompilieren des Kernels!"
    exit 1
fi

echo "Erstelle Floppy-Image..."
cat boot.bin kernel.bin > diffos.img
dd if=/dev/zero of=diffos.img bs=512 count=2880 conv=notrunc 2>/dev/null
dd if=boot.bin of=diffos.img conv=notrunc 2>/dev/null
dd if=kernel.bin of=diffos.img bs=512 seek=1 conv=notrunc 2>/dev/null

echo "Erstelle ISO-Image..."
mkdir -p iso
cp diffos.img iso/

if command -v genisoimage &> /dev/null; then
    genisoimage -o diffos.iso -b diffos.img -no-emul-boot iso/
elif command -v mkisofs &> /dev/null; then
    mkisofs -o diffos.iso -b diffos.img -no-emul-boot iso/
elif command -v xorriso &> /dev/null; then
    xorriso -as mkisofs -o diffos.iso -b diffos.img -no-emul-boot iso/
else
    echo "Warnung: Kein ISO-Tool gefunden (genisoimage/mkisofs/xorriso)"
    echo "Verwende diffos.img stattdessen"
fi

echo ""
echo "Fertig! diffos.iso wurde erstellt."
echo ""
echo "Zum Testen mit QEMU:"
echo "  qemu-system-i386 -cdrom diffos.iso"
echo "  oder"
echo "  qemu-system-i386 -fda diffos.img"
echo ""
