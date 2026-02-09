
<img width="1261" height="1007" alt="Logo01" src="https://github.com/user-attachments/assets/6d0b514c-d6e7-4b03-8d3f-4331bdfa0257" />

# DifferentOS Alpha 0.1

Ein minimales x86 Betriebssystem mit eigenem Bootloader, Kernel und BASIC-Interpreter.

## Features

- Eigener Bootloader der "DifferentOS Alpha 0.1" anzeigt
- Minimaler Kernel (ca. 15KB)
- Eingebauter BASIC-Interpreter
- Tastatur-Unterstützung
- Läuft auf x86-Prozessoren (Real Mode)

## BASIC-Befehle

- `PRINT "text"` - Text ausgeben
- `LET A=5` - Variable setzen (A-Z, Zahlen 0-9)
- `CLS` - Bildschirm löschen
- `HELP` - Hilfe anzeigen

## Kompilieren

Benötigt:
- nasm (Netwide Assembler)
- genisoimage oder mkisofs oder xorriso

```bash
make
```

Dies erstellt:
- boot.bin - Der Bootloader
- kernel.bin - Der Kernel
- diffos.img - Floppy-Image
- diffos.iso - ISO-Image

## Ausführen

### Mit QEMU:
```bash
qemu-system-i386 -cdrom diffos.iso
```

oder

```bash
qemu-system-i386 -fda diffos.img
```

### Mit VirtualBox:
1. Neue VM erstellen (Type: Other, Version: Other/Unknown)
2. diffos.iso als CD/DVD einbinden
3. VM starten

### Auf echter Hardware:
- diffos.iso auf CD brennen oder
- diffos.img auf Floppy schreiben

## Struktur

- boot.asm - Bootloader (Sektor 0)
- kernel.asm - Kernel mit BASIC-Interpreter (Sektor 1-30)

## Lizenz

Freie Verwendung für Lern- und Lehrzwecke.
