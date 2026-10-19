; NedohackOS stage 2: load the 64-bit kernel and enter x86-64 long mode.
; BIOS is used only before protected/long mode. Kernel is loaded at physical 0x10000.
use16
org 0x8000

stage2_entry:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    cld
    mov [boot_drive], dl

    ; Kernel starts at floppy CHS sector 10. Read sectors 10..18 (one track).
    mov ax, 0x1000
    mov es, ax
    xor bx, bx
    mov ah, 0x02
    mov al, 9
    mov ch, 0
    mov cl, 10
    mov dh, 0
    mov dl, [boot_drive]
    int 0x13
    jc disk_error

    ; Clear page tables at 0x9000, 0xA000, 0xB000.
    xor ax, ax
    mov es, ax
    mov di, 0x9000
    mov cx, 0x1800
    rep stosw

    ; PML4[0] = 0xA003, PDPT[0] = 0xB003, PD[0] = 0x0083 (2 MiB page).
    mov dword [0x9000], 0xA003
    mov dword [0x9004], 0
    mov dword [0xA000], 0xB003
    mov dword [0xA004], 0
    mov dword [0xB000], 0x0083
    mov dword [0xB004], 0

    lgdt [gdt_pointer]

    ; Enter 32-bit protected mode.
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp 0x08:protected_entry

disk_error:
    mov si, disk_error_message
.error_char:
    lodsb
    test al, al
    jz .halt
    mov ah, 0x0E
    mov bx, 0x0007
    int 0x10
    jmp .error_char
.halt:
    cli
    hlt
    jmp .halt

use32
protected_entry:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax
    mov esp, 0x70000

    ; Enable PAE, point CR3 at PML4, and enable long mode in EFER.
    mov eax, cr4
    or eax, 1 shl 5
    mov cr4, eax
    mov eax, 0x9000
    mov cr3, eax

    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 shl 8
    wrmsr

    ; Paging + protected mode, then far jump through the 64-bit code descriptor.
    mov eax, cr0
    or eax, (1 shl 31) or 1
    mov cr0, eax
    jmp 0x18:long_mode_entry

use64
long_mode_entry:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov rsp, 0x70000
    cld
    jmp 0x10000

align 8
gdt_start:
    dq 0
    dq 0x00CF9A000000FFFF ; 32-bit code
    dq 0x00CF92000000FFFF ; data
    dq 0x00AF9A000000FFFF ; 64-bit code
gdt_end:

gdt_pointer:
    dw gdt_end - gdt_start - 1
    dd gdt_start

boot_drive db 0
disk_error_message db 'NedohackOS: kernel disk read error', 0
