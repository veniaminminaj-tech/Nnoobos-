; NedohackersOS on FASM stage 2: BIOS setup, load kernel, enter x86-64 long mode.
use16
org 0x8000
stage2_entry:
    cli
    xor ax,ax
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov sp,0x7C00
    cld
    mov [boot_drive],dl
    ; Load up to 16 kernel sectors. First read reaches the end of head 0.
    mov ax,0x1000
    mov es,ax
    xor bx,bx
    mov ah,2
    mov al,9
    mov ch,0
    mov cl,10
    mov dh,0
    mov dl,[boot_drive]
    int 0x13
    jc disk_error
    ; Continue at head 1, sector 1 (next physical sector after sector 18).
    mov ax,0x1000
    mov es,ax
    mov bx,9*512
    mov ah,2
    mov al,7
    mov ch,0
    mov cl,1
    mov dh,1
    mov dl,[boot_drive]
    int 0x13
    jc disk_error
    ; Set 320x200x256-color VGA mode.
    mov ax,0x0013
    int 0x10
    ; Copy BIOS 8x16 font to physical 0x5000 before leaving real mode.
    mov ax,0x1130
    mov bh,0x06
    int 0x10
    push ds
    push es
    mov dx,es
    mov ds,dx
    mov si,bp
    xor ax,ax
    mov es,ax
    mov di,0x5000
    mov cx,2048
    rep movsw
    pop es
    pop ds
    ; Clear page tables at 0x9000..0xBFFF.
    xor ax,ax
    mov es,ax
    mov di,0x9000
    mov cx,0x1800
    rep stosw
    mov dword [0x9000],0xA003
    mov dword [0x9004],0
    mov dword [0xA000],0xB003
    mov dword [0xA004],0
    mov dword [0xB000],0x0083
    mov dword [0xB004],0
    lgdt [gdt_pointer]
    mov eax,cr0
    or eax,1
    mov cr0,eax
    jmp 0x08:protected_entry
disk_error:
    mov si,disk_error_message
.err:
    lodsb
    test al,al
    jz .halt
    mov ah,0x0E
    mov bx,7
    int 0x10
    jmp .err
.halt:
    cli
    hlt
    jmp .halt
use32
protected_entry:
    mov ax,0x10
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov fs,ax
    mov gs,ax
    mov esp,0x70000
    mov eax,cr4
    or eax,1 shl 5
    mov cr4,eax
    mov eax,0x9000
    mov cr3,eax
    mov ecx,0xC0000080
    rdmsr
    or eax,1 shl 8
    wrmsr
    mov eax,cr0
    or eax,(1 shl 31) or 1
    mov cr0,eax
    jmp 0x18:long_mode_entry
use64
long_mode_entry:
    mov ax,0x10
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov rsp,0x70000
    cld
    jmp 0x10000
align 8
gdt_start:
    dq 0
    dq 0x00CF9A000000FFFF
    dq 0x00CF92000000FFFF
    dq 0x00AF9A000000FFFF
gdt_end:
gdt_pointer:
    dw gdt_end-gdt_start-1
    dd gdt_start
boot_drive db 0
disk_error_message db 'NedohackersOS on FASM: kernel disk read error',0
