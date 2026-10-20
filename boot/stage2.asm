; NedohackOS stage 2: load the 64-bit kernel and enter long mode.
; FASM syntax. VBE is configured while the BIOS is still available.
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

    ; Try VESA 800x600x24 with a linear framebuffer (mode 115h).
    ; Kernel receives framebuffer base at 0x500, pitch at 0x504,
    ; and a success flag at 0x508.
    mov dword [0x500], 0
    mov dword [0x504], 0
    mov byte [0x508], 0
    mov ax, 0x4F01
    mov cx, 0x0115
    mov di, 0x6000
    int 0x10
    cmp ax, 0x004F
    jne .video_done
    cmp byte [0x6019], 24
    jne .video_done
    mov eax, [0x6028]
    mov [0x500], eax
    movzx eax, word [0x6010]
    mov [0x504], eax
    mov ax, 0x4F02
    mov bx, 0x4115
    int 0x10
    cmp ax, 0x004F
    jne .video_done
    mov byte [0x508], 1
.video_done:

    ; Kernel starts at floppy CHS sector 10. Read sectors 10..18.
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

    ; Clear page tables at 0x9000..0xEFFF.
    xor ax, ax
    mov es, ax
    mov di, 0x9000
    mov cx, 0x3000
    rep stosw

    ; PML4[0] = 0xA003; PDPT entries map the first 4 GiB via four PDs.
    mov dword [0x9000], 0xA003
    mov dword [0x9004], 0
    mov dword [0xA000], 0xB003
    mov dword [0xA004], 0
    mov dword [0xA008], 0xC003
    mov dword [0xA00C], 0
    mov dword [0xA010], 0xD003
    mov dword [0xA014], 0
    mov dword [0xA018], 0xE003
    mov dword [0xA01C], 0

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

    ; Identity-map 4 GiB with 2 MiB pages, including a VBE framebuffer.
    mov edi, 0xB000
    mov eax, 0x83
    mov ecx, 2048
.map_pages:
    mov [edi], eax
    mov dword [edi+4], 0
    add eax, 0x200000
    add edi, 8
    loop .map_pages

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
