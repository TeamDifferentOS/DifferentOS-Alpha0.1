[BITS 16]
[ORG 0x0000]

kernel_start:
    ; Setup segments
    mov ax, 0x1000
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0xFFFE

    ; Clear screen
    mov ax, 0x0003
    int 0x10

    ; Print welcome message
    mov si, welcome_msg
    call print_string

    ; Initialize BASIC
    call basic_init

basic_loop:
    ; Print prompt
    mov si, prompt
    call print_string

    ; Read input line
    mov di, input_buffer
    call read_line

    ; Check if empty
    cmp byte [input_buffer], 0
    je basic_loop

    ; Process command
    call process_command

    jmp basic_loop

; Print string (SI = pointer to string)
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

; Print newline
print_newline:
    pusha
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10
    popa
    ret

; Read line into DI buffer
read_line:
    pusha
    xor cx, cx
.loop:
    mov ah, 0x00
    int 0x16            ; Wait for key

    cmp al, 0x0D        ; Enter?
    je .done

    cmp al, 0x08        ; Backspace?
    je .backspace

    cmp cx, 255         ; Buffer full?
    jae .loop

    ; Echo character
    mov ah, 0x0E
    int 0x10

    ; Store in buffer
    stosb
    inc cx
    jmp .loop

.backspace:
    test cx, cx
    jz .loop

    ; Move cursor back
    mov ah, 0x0E
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10

    ; Remove from buffer
    dec di
    dec cx
    jmp .loop

.done:
    ; Null terminate
    xor al, al
    stosb

    call print_newline
    popa
    ret

; Initialize BASIC interpreter
basic_init:
    ; Clear variables
    mov di, variables
    mov cx, 26 * 2
    xor ax, ax
    rep stosw
    ret

; Process BASIC command
process_command:
    pusha
    mov si, input_buffer

    ; Skip leading spaces
.skip_spaces:
    lodsb
    cmp al, ' '
    je .skip_spaces
    dec si

    ; Check for PRINT command
    mov di, cmd_print
    call compare_string
    test ax, ax
    jnz .do_print

    ; Check for LET command
    mov si, input_buffer
    mov di, cmd_let
    call compare_string
    test ax, ax
    jnz .do_let

    ; Check for CLS command
    mov si, input_buffer
    mov di, cmd_cls
    call compare_string
    test ax, ax
    jnz .do_cls

    ; Check for HELP command
    mov si, input_buffer
    mov di, cmd_help
    call compare_string
    test ax, ax
    jnz .do_help

    ; Unknown command
    mov si, error_unknown
    call print_string
    jmp .done

.do_print:
    call basic_print
    jmp .done

.do_let:
    call basic_let
    jmp .done

.do_cls:
    mov ax, 0x0003
    int 0x10
    jmp .done

.do_help:
    mov si, help_text
    call print_string
    jmp .done

.done:
    popa
    ret

; Compare strings (SI and DI), return AX=1 if match
compare_string:
    pusha
.loop:
    mov al, [si]
    mov bl, [di]
    
    ; Convert to uppercase
    cmp al, 'a'
    jb .check1
    cmp al, 'z'
    ja .check1
    sub al, 32
.check1:
    cmp bl, 'a'
    jb .check2
    cmp bl, 'z'
    ja .check2
    sub bl, 32
.check2:

    cmp bl, 0
    je .match
    cmp al, bl
    jne .no_match
    inc si
    inc di
    jmp .loop

.match:
    ; Check if next char is space or end
    cmp byte [si], ' '
    je .return_match
    cmp byte [si], 0
    je .return_match
    jmp .no_match

.return_match:
    popa
    mov ax, 1
    ret

.no_match:
    popa
    xor ax, ax
    ret

; BASIC PRINT command
basic_print:
    pusha
    mov si, input_buffer
    
    ; Skip "PRINT "
.skip:
    lodsb
    cmp al, ' '
    jne .skip

    ; Skip additional spaces
.skip2:
    lodsb
    cmp al, ' '
    je .skip2
    dec si

    ; Check if it's a string (starts with ")
    lodsb
    cmp al, '"'
    je .print_string_literal
    dec si

    ; Otherwise just print the rest
    call print_string
    call print_newline
    jmp .done

.print_string_literal:
    ; Print until closing "
.loop:
    lodsb
    cmp al, '"'
    je .string_done
    cmp al, 0
    je .string_done
    
    mov ah, 0x0E
    int 0x10
    jmp .loop

.string_done:
    call print_newline

.done:
    popa
    ret

; BASIC LET command (simplified - just stores single digit)
basic_let:
    pusha
    mov si, input_buffer
    
    ; Skip "LET "
.skip:
    lodsb
    cmp al, ' '
    jne .skip

    ; Skip spaces
.skip2:
    lodsb
    cmp al, ' '
    je .skip2
    
    ; Get variable name (A-Z)
    mov bl, al
    sub bl, 'A'
    cmp bl, 26
    jae .error

    ; Skip to =
.find_eq:
    lodsb
    cmp al, '='
    jne .find_eq

    ; Skip spaces after =
.skip3:
    lodsb
    cmp al, ' '
    je .skip3

    ; Get number
    sub al, '0'
    cmp al, 10
    jae .error

    ; Store in variable
    xor bh, bh
    shl bx, 1
    mov [variables + bx], ax

    jmp .done

.error:
    mov si, error_syntax
    call print_string

.done:
    popa
    ret

; Data section
welcome_msg db 'DifferentOS BASIC Interpreter', 0x0D, 0x0A
            db 'Type HELP for commands', 0x0D, 0x0A, 0x0D, 0x0A, 0

prompt db 'READY', 0x0D, 0x0A, '> ', 0

help_text db 'Available commands:', 0x0D, 0x0A
          db '  PRINT "text" - Print text', 0x0D, 0x0A
          db '  LET A=5 - Set variable', 0x0D, 0x0A
          db '  CLS - Clear screen', 0x0D, 0x0A
          db '  HELP - Show this help', 0x0D, 0x0A, 0x0D, 0x0A, 0

cmd_print db 'PRINT', 0
cmd_let db 'LET', 0
cmd_cls db 'CLS', 0
cmd_help db 'HELP', 0

error_unknown db 'Unknown command', 0x0D, 0x0A, 0
error_syntax db 'Syntax error', 0x0D, 0x0A, 0

input_buffer times 256 db 0
variables times 26 dw 0  ; A-Z variables

times 15360-($-$$) db 0  ; Pad to 30 sectors
