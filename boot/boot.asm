use16
org BOOT_ORIGIN

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, BOOT_ORIGIN
    cld
    mov [boot_drive], dl

    ; Load 8 sectors starting at sector 2 to physical address 0x8000.
    ; The second stage must fit within 4096 bytes.
    mov ax, 0x0000
    mov es, ax
    mov bx, 0x8000
    mov ah, 0x02
    mov al, 8
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, [boot_drive]
    int 0x13
    jc disk_error

    jmp 0x0000:0x8000

disk_error:
    mov si, disk_error_message
.print_error:
    lodsb
    test al, al
    jz .halt
    mov ah, 0x0E
    mov bx, 0x0007
    int 0x10
    jmp .print_error
.halt:
    cli
.hang:
    hlt
    jmp .hang

boot_drive db 0
disk_error_message db 'NedohackersOS on FASM: disk read error', 0

if ($ - $$) > 510
    display 'ERROR: boot sector exceeds 510 bytes', 13, 10
    err
end if
rb 510 - ($ - $$)
dw BOOT_SIGNATURE
