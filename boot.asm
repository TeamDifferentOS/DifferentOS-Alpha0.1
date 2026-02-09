[BITS 16]
[ORG 0x7C00]

start:
    ; Setup segments
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Clear screen
    mov ax, 0x0003
    int 0x10

    ; Display boot message
    mov si, boot_msg
    call print_string

    ; Wait a moment
    mov cx, 0xFFFF
.wait:
    loop .wait

    ; Load kernel from disk
    mov bx, 0x1000      ; Load kernel at 0x1000:0x0000
    mov es, bx
    xor bx, bx
    
    mov ah, 0x02        ; Read sectors
    mov al, 30          ; Number of sectors to read
    mov ch, 0           ; Cylinder 0
    mov cl, 2           ; Sector 2
    mov dh, 0           ; Head 0
    mov dl, 0x00        ; Drive 0 (floppy)
    int 0x13
    
    jc load_error

    ; Jump to kernel
    jmp 0x1000:0x0000

load_error:
    mov si, error_msg
    call print_string
    jmp $

print_string:
    pusha
    mov ah, 0x0E
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    popa
    ret

boot_msg db 'DifferentOS Alpha 0.1', 0x0D, 0x0A, 'Loading kernel...', 0x0D, 0x0A, 0
error_msg db 'Error loading kernel!', 0x0D, 0x0A, 0

times 510-($-$$) db 0
dw 0xAA55
