# DifferentOS - Installations- und Kompilierungsanleitung

## Voraussetzungen

### Windows:
1. **NASM** (Netwide Assembler)
   - Download: https://www.nasm.us/
   - Oder via Chocolatey: `choco install nasm`
   
2. **mkisofs** (optional, für ISO-Erstellung)
   - Teil von cdrtools: http://smithii.com/cdrtools
   - Oder Rufus verwenden um .img auf USB zu schreiben

3. **QEMU** (zum Testen)
   - Download: https://www.qemu.org/download/#windows
   - Oder via Chocolatey: `choco install qemu`

### Linux:
```bash
# Debian/Ubuntu
sudo apt-get install nasm genisoimage qemu-system-x86

# Fedora/RHEL
sudo dnf install nasm genisoimage qemu-system-x86

# Arch Linux
sudo pacman -S nasm cdrtools qemu-system-x86
```

### macOS:
```bash
# Mit Homebrew
brew install nasm cdrtools qemu
```

## Kompilierung

### Methode 1: Build-Skript verwenden

**Windows:**
```
build.bat
```

**Linux/macOS:**
```bash
chmod +x build.sh
./build.sh
```

### Methode 2: Make verwenden

```bash
make
```

### Methode 3: Manuelle Kompilierung

```bash
# Bootloader kompilieren
nasm -f bin boot.asm -o boot.bin

# Kernel kompilieren
nasm -f bin kernel.asm -o kernel.bin

# Floppy-Image erstellen
cat boot.bin kernel.bin > diffos.img
dd if=/dev/zero of=diffos.img bs=512 count=2880 conv=notrunc

# ISO erstellen
mkdir -p iso
cp diffos.img iso/
genisoimage -o diffos.iso -b diffos.img -no-emul-boot iso/
```

## Ausführen und Testen

### Option 1: QEMU (Empfohlen)

**Mit ISO:**
```bash
qemu-system-i386 -cdrom diffos.iso
```

**Mit Floppy-Image:**
```bash
qemu-system-i386 -fda diffos.img
```

**Mit mehr Optionen:**
```bash
qemu-system-i386 -cdrom diffos.iso -m 16M -boot d
```

### Option 2: VirtualBox

1. VirtualBox öffnen
2. "Neu" klicken
3. Name: DifferentOS
4. Typ: Other
5. Version: Other/Unknown
6. RAM: 16 MB (minimal)
7. Keine Festplatte
8. VM erstellen
9. Einstellungen → Massenspeicher → CD-Symbol → diffos.iso auswählen
10. Starten

### Option 3: VMware

1. Neue virtuelle Maschine erstellen
2. "Custom" wählen
3. "I will install the operating system later"
4. Guest OS: Other → Other
5. RAM: 16 MB
6. VM Settings → CD/DVD → Use ISO image → diffos.iso
7. Power On

### Option 4: Echte Hardware

**CD/DVD:**
1. diffos.iso auf CD brennen
2. Von CD booten

**USB (mit Rufus auf Windows):**
1. Rufus herunterladen
2. USB-Stick auswählen
3. "DD Image" Modus
4. diffos.img auswählen
5. Start
6. Von USB booten

**Floppy (falls vorhanden):**
```bash
dd if=diffos.img of=/dev/fd0  # Linux
```

## Verwendung von DifferentOS

Nach dem Booten siehst du:
```
DifferentOS Alpha 0.1
Loading kernel...

DifferentOS BASIC Interpreter
Type HELP for commands

READY
> 
```

### BASIC-Befehle:

**Hilfe anzeigen:**
```
HELP
```

**Text ausgeben:**
```
PRINT "Hello World"
PRINT "DifferentOS ist toll!"
```

**Variable setzen:**
```
LET A=5
LET B=3
```

**Bildschirm löschen:**
```
CLS
```

### Bekannte Einschränkungen:

- Nur Tastatur, keine Maus
- Nur Real Mode (16-bit)
- Einfacher BASIC-Interpreter (keine Berechnungen, Schleifen, etc.)
- Variablen: A-Z, nur einzelne Ziffern 0-9
- Keine Dateisystem-Unterstützung

## Troubleshooting

**"Boot failed" oder "No bootable device":**
- Stelle sicher, dass die VM/Computer von CD oder Floppy bootet
- Im BIOS die Boot-Reihenfolge prüfen

**"Error loading kernel":**
- Image könnte beschädigt sein
- Neu kompilieren

**NASM nicht gefunden:**
- NASM installieren (siehe Voraussetzungen)
- PATH-Variable prüfen

**Schwarzer Bildschirm in QEMU:**
- Normal, warte einige Sekunden
- Versuche: `qemu-system-i386 -cdrom diffos.iso -nographic` dann Ctrl+A, C für Monitor

## Weiterentwicklung

Das OS ist sehr einfach gehalten. Erweiterungsmöglichkeiten:

1. Erweiterte BASIC-Funktionen (Berechnungen, Schleifen, IF/THEN)
2. Mehrstellige Zahlen in Variablen
3. Protected Mode (32-bit)
4. Einfaches Dateisystem
5. Mehr Kommandos
6. Farbunterstützung
7. Grafik-Modus

## Lizenz

Freie Verwendung für Bildung und Experimente.
