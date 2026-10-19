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
    sti

    mov si, boot_message

.print:
    lodsb
    test al, al
    jz .halt
    mov ah, 0x0E
    int 0x10
    jmp .print

.halt:
    cli
.hang:
    hlt
    jmp .hang

boot_message db 'Nnoobos: boot OK!', 0

if ($ - $$) > 510
    display 'ERROR: boot sector exceeds 510 bytes', 13, 10
    err
end if

rb 510 - ($ - $$)
dw BOOT_SIGNATURE
