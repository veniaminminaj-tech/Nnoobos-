; Nnoobos second stage: text-mode desktop and Linux-like shell.
; Runs in BIOS 16-bit real mode. This is not motherboard firmware.

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
    sti
    call draw_desktop

main_loop:
    xor ah, ah
    int 0x16
    cmp ah, 0x3B          ; F1 Start menu
    je .start_menu
    cmp ah, 0x3C          ; F2 system info
    je .system_info
    cmp ah, 0x3D          ; F3 setup screen
    je .setup
    cmp ah, 0x3E          ; F4 reboot
    je .reboot
    cmp ah, 0x3F          ; F5 terminal
    je .terminal
    cmp al, 27
    je .desktop
    jmp main_loop
.start_menu:
    call draw_start_menu
.menu_wait:
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
    cmp ah, 0x3F
    je .terminal
    jmp .menu_wait
.system_info:
    call draw_system_info
    xor ah, ah
    int 0x16
    jmp .desktop
.setup:
    call draw_setup
    xor ah, ah
    int 0x16
    jmp .desktop
.terminal:
    call terminal
    jmp .desktop
.desktop:
    call draw_desktop
    jmp main_loop
.reboot:
    int 0x19
    jmp $

; print_at: DH=row, DL=column, BL=attribute, SI=zero-terminated text
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
.next:
    lodsb
    test al, al
    jz .done
    mov ah, bl
    mov [es:di], ax
    add di, 2
    jmp .next
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
    mov dh, 2
    mov dl, 2
    mov bl, 0x1E
    mov si, icon_computer
    call print_at
    mov dh, 5
    mov dl, 2
    mov bl, 0x1E
    mov si, icon_files
    call print_at
    mov dh, 8
    mov dl, 2
    mov bl, 0x1E
    mov si, icon_terminal
    call print_at

    ; Main welcome window
    mov dh, 2
    mov dl, 23
    mov bl, 0x1F
    mov si, win_top
    call print_at
    mov dh, 3
    mov dl, 23
    mov bl, 0x1F
    mov si, win_line1
    call print_at
    mov dh, 4
    mov dl, 23
    mov bl, 0x1F
    mov si, win_line2
    call print_at
    mov dh, 5
    mov dl, 23
    mov bl, 0x1F
    mov si, win_line3
    call print_at
    mov dh, 6
    mov dl, 23
    mov bl, 0x1F
    mov si, win_line4
    call print_at
    mov dh, 7
    mov dl, 23
    mov bl, 0x1F
    mov si, win_bottom
    call print_at

    mov dh, 21
    mov dl, 0
    mov bl, 0x70
    mov si, taskbar
    call print_at
    mov dh, 22
    mov dl, 0
    mov bl, 0x70
    mov si, shortcuts
    call print_at
    mov dh, 23
    mov dl, 0
    mov bl, 0x70
    mov si, status_line
    call print_at
    ret

draw_start_menu:
    mov dh, 12
    mov dl, 1
    mov bl, 0x70
    mov si, menu_top
    call print_at
    mov dh, 13
    mov dl, 1
    mov bl, 0x70
    mov si, menu_system
    call print_at
    mov dh, 14
    mov dl, 1
    mov bl, 0x70
    mov si, menu_setup
    call print_at
    mov dh, 15
    mov dl, 1
    mov bl, 0x70
    mov si, menu_terminal
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

; ------------------------------------------------------------
; Linux-like interactive command shell (not Linux itself).
; Commands: help, clear, uname, ls, desktop, reboot, echo TEXT, exit
; ------------------------------------------------------------
terminal:
    mov ax, 0x0003
    int 0x10
    mov si, term_banner
    call bios_print
.term_prompt:
    mov si, term_prompt_text
    call bios_print
    mov di, command_buffer
    xor cx, cx
.term_read:
    xor ah, ah
    int 0x16
    cmp al, 13
    je .term_enter
    cmp al, 8
    je .term_backspace
    cmp al, 27
    je .term_exit
    cmp al, 32
    jb .term_read
    cmp cx, 78
    jae .term_read
    stosb
    inc cx
    mov ah, 0x0E
    mov bh, 0
    mov bl, 0x07
    int 0x10
    jmp .term_read
.term_backspace:
    cmp cx, 0
    je .term_read
    dec di
    dec cx
    mov byte [di], 0
    mov ah, 0x0E
    mov al, 8
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 8
    int 0x10
    jmp .term_read
.term_enter:
    mov byte [di], 0
    call bios_newline
    mov si, command_buffer
    mov di, cmd_help
    call compare_command
    cmp al, 1
    je .cmd_help
    mov si, command_buffer
    mov di, cmd_clear
    call compare_command
    cmp al, 1
    je .cmd_clear
    mov si, command_buffer
    mov di, cmd_uname
    call compare_command
    cmp al, 1
    je .cmd_uname
    mov si, command_buffer
    mov di, cmd_ls
    call compare_command
    cmp al, 1
    je .cmd_ls
    mov si, command_buffer
    mov di, cmd_desktop
    call compare_command
    cmp al, 1
    je .term_exit
    mov si, command_buffer
    mov di, cmd_exit
    call compare_command
    cmp al, 1
    je .term_exit
    mov si, command_buffer
    mov di, cmd_reboot
    call compare_command
    cmp al, 1
    je .cmd_reboot
    mov si, command_buffer
    mov di, cmd_echo
    call starts_with_echo
    cmp al, 1
    je .cmd_echo
    mov si, msg_not_found
    call bios_print
    jmp .term_prompt
.cmd_help:
    mov si, msg_help
    call bios_print
    jmp .term_prompt
.cmd_clear:
    mov ax, 0x0003
    int 0x10
    mov si, term_banner
    call bios_print
    jmp .term_prompt
.cmd_uname:
    mov si, msg_uname
    call bios_print
    jmp .term_prompt
.cmd_ls:
    mov si, msg_ls
    call bios_print
    jmp .term_prompt
.cmd_echo:
    mov si, command_buffer
    add si, 5
    call bios_print
    call bios_newline
    jmp .term_prompt
.cmd_reboot:
    int 0x19
    jmp $
.term_exit:
    ret

; compare_command returns AL=1 if both zero-terminated strings match.
compare_command:
    push si
    push di
.compare_loop:
    mov al, [si]
    mov ah, [di]
    cmp al, ah
    jne .not_equal
    test al, al
    jz .equal
    inc si
    inc di
    jmp .compare_loop
.equal:
    mov al, 1
    jmp .compare_done
.not_equal:
    mov al, 0
.compare_done:
    pop di
    pop si
    ret

; Check whether command starts with "echo ".
starts_with_echo:
    push si
    push di
    mov di, echo_prefix
.echo_loop:
    mov al, [di]
    test al, al
    jz .echo_yes
    cmp al, [si]
    jne .echo_no
    inc si
    inc di
    jmp .echo_loop
.echo_yes:
    mov al, 1
    jmp .echo_done
.echo_no:
    mov al, 0
.echo_done:
    pop di
    pop si
    ret

bios_print:
    push ax
    push bx
    push si
.print_loop:
    lodsb
    test al, al
    jz .print_done
    mov ah, 0x0E
    mov bh, 0
    mov bl, 0x07
    int 0x10
    jmp .print_loop
.print_done:
    pop si
    pop bx
    pop ax
    ret

bios_newline:
    push ax
    push bx
    mov ah, 0x0E
    mov al, 13
    mov bh, 0
    int 0x10
    mov al, 10
    int 0x10
    pop bx
    pop ax
    ret

title_bar       db ' NNOOBOS | DESKTOP                                     _ [] X ', 0
icon_computer   db '[PC]  This PC', 0
icon_files      db '[DIR] Files', 0
icon_terminal   db '[>_]  Terminal (F5)', 0
win_top         db '+---------------------- Welcome -----------------------+', 0
win_line1       db '|                                                      |', 0
win_line2       db '|   Welcome to Nnoobos                                 |', 0
win_line3       db '|   F1 Start  F2 System  F3 Setup  F5 Terminal         |', 0
win_line4       db '|   Linux-like shell: help, uname, ls, echo, clear     |', 0
win_bottom      db '+------------------------------------------------------+', 0
taskbar         db ' [ START ]   [ Desktop ] [ Terminal ]                    NNOOBOS ', 0
shortcuts       db 'F1 Start Menu | F2 System | F3 Setup | F4 Reboot | F5 Console', 0
status_line     db 'Nnoobos OS - early x86 real-mode build', 0
menu_top        db '+---------------------- NNOOBOS ----------------------+', 0
menu_system     db '|  F2  System Information                             |', 0
menu_setup      db '|  F3  Setup screen (simulation)                      |', 0
menu_terminal   db '|  F5  Open command terminal                          |', 0
menu_reboot     db '|  F4  Restart computer                               |', 0
menu_close      db '|  ESC/F1  Close menu                                 |', 0
info_title      db 'Nnoobos - System Information', 0
info_line1      db 'Architecture: x86, 16-bit real mode prototype', 0
info_line2      db 'Display: VGA text mode via BIOS / video memory', 0
info_line3      db 'Protected mode and a full kernel are not implemented yet.', 0
setup_header    db ' NNOOBOS FIRMWARE SETUP (SIMULATED) ', 0
setup_line1     db 'Boot mode: BIOS real mode', 0
setup_line2     db 'Video: 80x25 text mode', 0
setup_line3     db 'Disk: boot sector + second-stage program', 0
setup_warning   db 'This is an OS menu, NOT the motherboard BIOS setup.', 0
press_key       db 'Press any key to return...', 0
term_banner     db 'Nnoobos Terminal 0.1 - minimal shell (not Linux)', 13, 10, 'Type help for commands.', 13, 10, 13, 10, 0
term_prompt_text db 'nnoobos@os:~$ ', 0
cmd_help        db 'help', 0
cmd_clear       db 'clear', 0
cmd_uname       db 'uname', 0
cmd_ls          db 'ls', 0
cmd_desktop     db 'desktop', 0
cmd_exit        db 'exit', 0
cmd_reboot      db 'reboot', 0
echo_prefix     db 'echo ', 0
msg_help        db 'Commands: help clear uname ls echo TEXT desktop exit reboot', 13, 10, 0
msg_uname       db 'Nnoobos x86 - BIOS real mode prototype', 13, 10, 0
msg_ls          db 'Desktop/  Documents/  System/  terminal', 13, 10, 0
msg_not_found   db 'nnoobos: command not found. Type help.', 13, 10, 0
command_buffer  rb 80
