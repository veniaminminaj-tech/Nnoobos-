; Nnoobos second stage: BIOS text-mode desktop prototype.
; This is an OS-owned interface using BIOS video/keyboard services,
; NOT a replacement for motherboard BIOS firmware.

use16
org 0x8000

stage2_entry:
    cli
    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov sp, 0x7C00
    cld
    sti

    call draw_desktop

main_loop:
    xor ah, ah
    int 0x16

    cmp ah, 0x3B          ; F1: Start menu
    je .start_menu
    cmp ah, 0x3C          ; F2: system information
    je .system_info
    cmp ah, 0x3D          ; F3: BIOS-style setup screen (simulation)
    je .setup
    cmp ah, 0x3E          ; F4: reboot through BIOS
    je .reboot
    cmp al, 27            ; Esc: redraw desktop
    je .desktop
    jmp main_loop

.start_menu:
    call draw_start_menu
.wait_menu:
    xor ah, ah
    int 0x16
    cmp ah, 0x3B
    je .desktop
    cmp al, 27
    je .desktop
    cmp ah, 0x3C
    je .system_info
    cmp ah, 0x3D
    je .setup
    cmp ah, 0x3E
    je .reboot
    jmp .wait_menu

.system_info:
    call draw_system_info
    xor ah, ah
    int 0x16
    call draw_desktop
    jmp main_loop

.setup:
    call draw_setup
    xor ah, ah
    int 0x16
    call draw_desktop
    jmp main_loop

.desktop:
    call draw_desktop
    jmp main_loop

.reboot:
    int 0x19
    jmp $

; ------------------------------------------------------------
; Screen drawing helpers. print_at: DH=row, DL=column,
; BL=VGA text attribute, SI=zero-terminated string.
; ------------------------------------------------------------
clear_screen:
    push ax
    push cx
    push di
    push es
    mov ax, 0xB800
    mov es, ax
    xor di, di
    mov ax, 0x1F20
    mov cx, 2000
    rep stosw
    pop es
    pop di
    pop cx
    pop ax
    ret

print_at:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es
    xor ax, ax
    mov al, dh
    mov cx, 160
    mul cx
    mov di, ax
    xor ax, ax
    mov al, dl
    shl ax, 1
    add di, ax
    mov ax, 0xB800
    mov es, ax
.next_char:
    lodsb
    test al, al
    jz .done
    mov ah, bl
    mov [es:di], ax
    add di, 2
    jmp .next_char
.done:
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

draw_desktop:
    call clear_screen
    mov dh, 0
    mov dl, 0
    mov bl, 0x70
    mov si, title_bar
    call print_at

    mov dh, 3
    mov dl, 3
    mov bl, 0x1E
    mov si, computer_icon
    call print_at

    mov dh, 7
    mov dl, 3
    mov bl, 0x1E
    mov si, docs_icon
    call print_at

    mov dh, 3
    mov dl, 24
    mov bl, 0x1A
    mov si, welcome_text
    call print_at

    mov dh, 5
    mov dl, 24
    mov bl, 0x1F
    mov si, help_text
    call print_at

    mov dh, 22
    mov dl, 0
    mov bl, 0x70
    mov si, taskbar
    call print_at

    mov dh, 23
    mov dl, 0
    mov bl, 0x70
    mov si, shortcut_text
    call print_at
    ret

draw_start_menu:
    mov dh, 13
    mov dl, 1
    mov bl, 0x70
    mov si, menu_top
    call print_at
    mov dh, 14
    mov dl, 1
    mov bl, 0x70
    mov si, menu_system
    call print_at
    mov dh, 15
    mov dl, 1
    mov bl, 0x70
    mov si, menu_setup
    call print_at
    mov dh, 16
    mov dl, 1
    mov bl, 0x70
    mov si, menu_reboot
    call print_at
    mov dh, 17
    mov dl, 1
    mov bl, 0x70
    mov si, menu_close
    call print_at
    ret

draw_system_info:
    call clear_screen
    mov dh, 2
    mov dl, 2
    mov bl, 0x1E
    mov si, info_title
    call print_at
    mov dh, 5
    mov dl, 2
    mov bl, 0x1F
    mov si, info_line1
    call print_at
    mov dh, 7
    mov dl, 2
    mov bl, 0x1F
    mov si, info_line2
    call print_at
    mov dh, 9
    mov dl, 2
    mov bl, 0x1F
    mov si, info_line3
    call print_at
    mov dh, 12
    mov dl, 2
    mov bl, 0x70
    mov si, press_key
    call print_at
    ret

draw_setup:
    call clear_screen
    mov dh, 1
    mov dl, 0
    mov bl, 0x70
    mov si, setup_header
    call print_at
    mov dh, 4
    mov dl, 2
    mov bl, 0x1F
    mov si, setup_line1
    call print_at
    mov dh, 6
    mov dl, 2
    mov bl, 0x1F
    mov si, setup_line2
    call print_at
    mov dh, 8
    mov dl, 2
    mov bl, 0x1F
    mov si, setup_line3
    call print_at
    mov dh, 12
    mov dl, 2
    mov bl, 0x4F
    mov si, setup_warning
    call print_at
    mov dh, 15
    mov dl, 2
    mov bl, 0x70
    mov si, press_key
    call print_at
    ret

title_bar       db ' NNOOBOS DESKTOP - BIOS TEXT MODE ', 0
computer_icon   db '[PC] My Computer', 0
docs_icon       db '[DIR] Files', 0
welcome_text    db 'Welcome to Nnoobos!', 0
help_text       db 'Press F1 for Start, F2 for System, F3 for Setup.', 0
taskbar         db ' [ START ]     Nnoobos OS                               x86 ', 0
shortcut_text  db 'F1 Start Menu  |  F2 System Info  |  F3 Setup  |  F4 Reboot', 0
menu_top        db '+---------------------- NNOOBOS ----------------------+', 0
menu_system     db '|  F2  System Information                             |', 0
menu_setup      db '|  F3  BIOS Setup screen (simulation)                 |', 0
menu_reboot     db '|  F4  Restart computer                               |', 0
menu_close      db '|  ESC/F1  Close menu                                 |', 0
info_title      db 'Nnoobos - System Information', 0
info_line1      db 'Architecture: x86, 16-bit real mode prototype', 0
info_line2      db 'Display: VGA text mode via BIOS / video memory', 0
info_line3      db 'Kernel loading and protected mode are not implemented yet.', 0
setup_header    db ' NNOOBOS FIRMWARE SETUP (SIMULATED) ', 0
setup_line1     db 'Boot mode: BIOS real mode', 0
setup_line2     db 'Video: 80x25 text mode', 0
setup_line3     db 'Disk: boot sector + second-stage program', 0
setup_warning   db 'This is an OS menu, NOT the motherboard BIOS setup.', 0
press_key       db 'Press any key to return...', 0
