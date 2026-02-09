#!/usr/bin/env python3
"""
DifferentOS Builder - Erstellt Boot- und Kernel-Binaries ohne NASM
"""

def create_bootloader():
    """Erstellt den Bootloader als Binärdatei"""
    # Handcodierter Bootloader in Maschinencode
    bootloader = bytearray([
        # xor ax, ax
        0x31, 0xC0,
        # mov ds, ax
        0x8E, 0xD8,
        # mov es, ax
        0x8E, 0xC0,
        # mov ss, ax
        0x8E, 0xD0,
        # mov sp, 0x7C00
        0xBC, 0x00, 0x7C,
        
        # mov ax, 0x0003 (Video-Modus 80x25 Text)
        0xB8, 0x03, 0x00,
        # int 0x10
        0xCD, 0x10,
        
        # mov si, boot_msg (Offset 0x50)
        0xBE, 0x50, 0x7C,
        # call print_string (Offset zu 0x35)
        0xE8, 0x1E, 0x00,
        
        # Warte-Schleife: mov cx, 0xFFFF
        0xB9, 0xFF, 0xFF,
        # loop $ (dec cx; jnz)
        0xE2, 0xFE,
        
        # Load kernel: mov bx, 0x1000
        0xBB, 0x00, 0x10,
        # mov es, bx
        0x8E, 0xC3,
        # xor bx, bx
        0x31, 0xDB,
        
        # mov ah, 0x02 (Read sectors)
        0xB4, 0x02,
        # mov al, 30 (Anzahl Sektoren)
        0xB0, 0x1E,
        # mov ch, 0 (Cylinder)
        0xB5, 0x00,
        # mov cl, 2 (Sector)
        0xB1, 0x02,
        # mov dh, 0 (Head)
        0xB6, 0x00,
        # mov dl, 0x00 (Drive)
        0xB2, 0x00,
        # int 0x13
        0xCD, 0x13,
        
        # jmp 0x1000:0x0000
        0xEA, 0x00, 0x00, 0x00, 0x10,
        
        # print_string: pusha
        0x60,
        # mov ah, 0x0E
        0xB4, 0x0E,
        # lodsb
        0xAC,
        # test al, al
        0x84, 0xC0,
        # jz +4
        0x74, 0x04,
        # int 0x10
        0xCD, 0x10,
        # jmp -8
        0xEB, 0xF6,
        # popa
        0x61,
        # ret
        0xC3,
    ])
    
    # Boot-Nachricht bei Offset 0x50
    msg = b'DifferentOS Alpha 0.1\r\nLoading kernel...\r\n\0'
    bootloader.extend([0] * (0x50 - len(bootloader)))  # Padding
    bootloader.extend(msg)
    
    # Padding bis zum Ende (510 Bytes)
    bootloader.extend([0] * (510 - len(bootloader)))
    
    # Boot-Signatur
    bootloader.extend([0x55, 0xAA])
    
    return bytes(bootloader)

def create_kernel():
    """Erstellt den Kernel als Binärdatei"""
    # Vereinfachter Kernel
    kernel = bytearray([
        # Setup segments
        0xB8, 0x00, 0x10,  # mov ax, 0x1000
        0x8E, 0xD8,        # mov ds, ax
        0x8E, 0xC0,        # mov es, ax
        0x8E, 0xD0,        # mov ss, ax
        0xBC, 0xFE, 0xFF,  # mov sp, 0xFFFE
        
        # Clear screen
        0xB8, 0x03, 0x00,  # mov ax, 0x0003
        0xCD, 0x10,        # int 0x10
        
        # Print welcome message
        0xBE, 0x50, 0x00,  # mov si, welcome_msg
        0xE8, 0x0A, 0x00,  # call print_string
        
        # Main loop: print prompt
        0xBE, 0xA0, 0x00,  # mov si, prompt
        0xE8, 0x04, 0x00,  # call print_string
        
        # Read character and loop
        0xB4, 0x00,        # mov ah, 0x00
        0xCD, 0x16,        # int 0x16
        0xB4, 0x0E,        # mov ah, 0x0E
        0xCD, 0x10,        # int 0x10
        0xEB, 0xEE,        # jmp main_loop
        
        # print_string function
        0x60,              # pusha
        0xB4, 0x0E,        # mov ah, 0x0E
        0xAC,              # lodsb
        0x84, 0xC0,        # test al, al
        0x74, 0x04,        # jz done
        0xCD, 0x10,        # int 0x10
        0xEB, 0xF6,        # jmp loop
        0x61,              # popa
        0xC3,              # ret
    ])
    
    # Nachrichten
    kernel.extend([0] * (0x50 - len(kernel)))  # Padding
    welcome = b'DifferentOS BASIC Interpreter\r\nType HELP for commands\r\n\r\n\0'
    kernel.extend(welcome)
    
    kernel.extend([0] * (0xA0 - len(kernel)))  # Padding
    prompt = b'READY\r\n> \0'
    kernel.extend(prompt)
    
    # Padding auf 15KB (30 Sektoren)
    kernel.extend([0] * (15360 - len(kernel)))
    
    return bytes(kernel)

def create_floppy_image():
    """Erstellt ein vollständiges 1.44MB Floppy-Image"""
    boot = create_bootloader()
    kernel = create_kernel()
    
    # 1.44MB = 2880 Sektoren * 512 Bytes
    image = bytearray(2880 * 512)
    
    # Bootloader im ersten Sektor
    image[0:512] = boot
    
    # Kernel ab Sektor 2
    image[512:512 + len(kernel)] = kernel
    
    return bytes(image)

def main():
    print("Erstelle DifferentOS Binärdateien...")
    
    # Einzelne Komponenten
    print("- Erstelle boot.bin...")
    with open('boot.bin', 'wb') as f:
        f.write(create_bootloader())
    
    print("- Erstelle kernel.bin...")
    with open('kernel.bin', 'wb') as f:
        f.write(create_kernel())
    
    # Floppy-Image
    print("- Erstelle diffos.img...")
    with open('diffos.img', 'wb') as f:
        f.write(create_floppy_image())
    
    print("\nFertig!")
    print("Dateien erstellt:")
    print("  - boot.bin (512 Bytes)")
    print("  - kernel.bin (15360 Bytes)")
    print("  - diffos.img (1.44 MB)")
    print("\nZum Testen:")
    print("  qemu-system-i386 -fda diffos.img")

if __name__ == '__main__':
    main()
