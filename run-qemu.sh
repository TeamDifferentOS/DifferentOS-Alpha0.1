#!/bin/bash

echo "Starte DifferentOS in QEMU..."
echo ""
echo "Hinweis: Drücke Ctrl+Alt+G um Maus/Tastatur freizugeben"
echo "         Drücke Ctrl+Alt+F um Vollbild zu togglen"
echo ""

if [ -f diffos.iso ]; then
    qemu-system-i386 -cdrom diffos.iso -m 16M
elif [ -f diffos.img ]; then
    qemu-system-i386 -fda diffos.img -m 16M
else
    echo "FEHLER: Keine diffos.iso oder diffos.img gefunden!"
    echo "Bitte erst kompilieren mit: ./build.sh"
    exit 1
fi
