; Nnoobos graphical desktop prototype for BIOS VGA mode 13h (320x200).
; BIOS font is copied to 0x5000 by stage2. Keyboard shortcuts:
; S = Start menu, 1 = Files, 2 = Notes, 3 = Calculator, 0 = Desktop.
use64
org 0x10000
kernel_entry:
    cli
    cld
    mov rsp,0x70000
    call serial_init
    mov rsi,kernel_banner
    call serial_write
    call boot_choice
    cmp al,2
    je .terminal
    mov rdi,0xA0000
    mov ecx,64000
    mov al,1
    rep stosb
    ; Header and taskbar
    mov edi,0
    mov esi,0
    mov edx,320
    mov ecx,20
    mov r8d,1
    call rect
    mov edi,0
    mov esi,180
    mov edx,320
    mov ecx,20
    mov r8d,8
    call rect
    mov edi,5
    mov esi,182
    mov edx,36
    mov ecx,16
    mov r8d,14
    call rect
    mov edi,10
    mov esi,182
    mov rsi,desktop_title
    mov edx,182
    mov ecx,4
    call text
    ; Desktop icon tiles
    mov edi,18
    mov esi,42
    mov edx,30
    mov ecx,26
    mov r8d,14
    call rect
    mov edi,22
    mov esi,46
    mov edx,22
    mov ecx,18
    mov r8d,3
    call rect
    mov edi,13
    mov esi,70
    mov rsi,files_label
    mov edx,70
    mov ecx,15
    call text
    mov edi,66
    mov esi,42
    mov edx,30
    mov ecx,26
    mov r8d,14
    call rect
    mov edi,70
    mov esi,46
    mov edx,22
    mov ecx,18
    mov r8d,6
    call rect
    mov edi,61
    mov esi,70
    mov rsi,notes_label
    mov edx,70
    mov ecx,15
    call text
    mov edi,114
    mov esi,42
    mov edx,30
    mov ecx,26
    mov r8d,14
    call rect
    mov edi,118
    mov esi,46
    mov edx,22
    mov ecx,18
    mov r8d,12
    call rect
    mov edi,109
    mov esi,70
    mov rsi,calc_label
    mov edx,70
    mov ecx,15
    call text
    mov edi,12
    mov esi,9
    mov rsi,brand_label
    mov edx,9
    mov ecx,15
    call text
    mov rsi,ready_line
    mov edi,15
    mov edx,105
    mov ecx,15
    call text
    mov rsi,help_line
    mov edi,15
    mov edx,126
    mov ecx,15
    call text
.loop:
    in al,0x64
    test al,1
    jz .loop
    in al,0x60
    test al,0x80
    jnz .loop
    cmp byte [shell_active],1
    je .shell_key
    cmp al,0x14              ; T = terminal
    je .terminal
    cmp al,0x1F              ; S = Start
    je .start
    cmp al,0x02              ; 1 = Files
    je .files
    cmp al,0x03              ; 2 = Notes
    je .notes
    cmp al,0x04              ; 3 = Calculator
    je .calc
    cmp al,0x0B              ; 0 = desktop redraw
    je .desktop
    jmp .loop
.terminal:
    mov byte [shell_active],1
    call shell_draw
    jmp .loop
.shell_key:
    cmp al,0x14              ; T exits terminal
    je .terminal_exit
    cmp al,0x1C              ; Enter
    je .shell_enter
    cmp al,0x0E              ; Backspace
    je .shell_backspace
    cmp al,0x39              ; Space
    je .shell_space
    ; Translate common US keyboard scan codes to lowercase ASCII.
    movzx ebx,al
    cmp ebx,57
    ja .loop
    mov al,[scan_ascii+rbx]
    test al,al
    jz .loop
    movzx ebx,byte [shell_len]
    cmp ebx,63
    jae .loop
    mov [shell_input+rbx],al
    inc byte [shell_len]
    mov byte [shell_input+rbx+1],0
    call shell_draw
    jmp .loop
.shell_space:
    movzx ebx,byte [shell_len]
    cmp ebx,63
    jae .loop
    mov byte [shell_input+rbx],' '
    inc byte [shell_len]
    mov byte [shell_input+rbx+1],0
    call shell_draw
    jmp .loop
.shell_backspace:
    cmp byte [shell_len],0
    je .loop
    dec byte [shell_len]
    movzx ebx,byte [shell_len]
    mov byte [shell_input+rbx],0
    call shell_draw
    jmp .loop
.shell_enter:
    call shell_execute
    mov byte [shell_len],0
    mov byte [shell_input],0
    call shell_draw
    jmp .loop
.terminal_exit:
    mov byte [shell_active],0
    jmp kernel_entry
.start:
    mov edi,4
    mov esi,112
    mov edx,128
    mov ecx,64
    mov r8d,7
    call rect
    mov edi,8
    mov esi,116
    mov edx,120
    mov ecx,56
    mov r8d,1
    call rect
    mov edi,16
    mov esi,120
    mov rsi,start_title
    mov edx,120
    mov ecx,15
    call text
    mov edi,16
    mov esi,140
    mov rsi,start_items
    mov edx,140
    mov ecx,15
    call text
    jmp .loop
.files:
    mov rsi,files_title
    mov rdi,100
    mov edx,42
    mov ecx,15
    call app_window
    jmp .loop
.notes:
    mov rsi,notes_title
    mov rdi,100
    mov edx,42
    mov ecx,15
    call app_window
    jmp .loop
.calc:
    mov rsi,calc_title
    mov rdi,100
    mov edx,42
    mov ecx,15
    call app_window
    jmp .loop
.desktop:
    ; Redraw desktop by rebooting; keyboard shortcut remains responsive.
    jmp kernel_entry

; Minimal Linux-like command line (not a Linux kernel or GNU/Linux environment).
; T toggles terminal. Supported commands: help, clear, uname, pwd, ls, whoami.
shell_draw:
    mov rdi,0
    mov rsi,0
    mov rdx,320
    mov rcx,200
    mov r8d,0
    call rect
    mov rdi,8
    mov rsi,terminal_title
    mov edx,8
    mov ecx,10
    call text
    mov rdi,8
    mov rsi,shell_result
    mov edx,35
    mov ecx,10
    call text
    mov rdi,8
    mov rsi,shell_prompt
    mov edx,160
    mov ecx,10
    call text
    mov rdi,120
    mov rsi,shell_input
    mov edx,160
    mov ecx,15
    call text
    mov rdi,8
    mov rsi,shell_hint
    mov edx,182
    mov ecx,7
    call text
    ret

shell_execute:
    mov rsi,shell_input
    mov rdi,cmd_help
    call str_equal
    test al,al
    jnz .help
    mov rsi,shell_input
    mov rdi,cmd_clear
    call str_equal
    test al,al
    jnz .clear
    mov rsi,shell_input
    mov rdi,cmd_uname
    call str_equal
    test al,al
    jnz .uname
    mov rsi,shell_input
    mov rdi,cmd_pwd
    call str_equal
    test al,al
    jnz .pwd
    mov rsi,shell_input
    mov rdi,cmd_ls
    call str_equal
    test al,al
    jnz .ls
    mov rsi,shell_input
    mov rdi,cmd_whoami
    call str_equal
    test al,al
    jnz .whoami
    mov rsi,shell_input
    mov rdi,cmd_version
    call str_equal
    test al,al
    jnz .version
    mov rsi,shell_input
    mov rdi,cmd_hostname
    call str_equal
    test al,al
    jnz .hostname
    mov rsi,shell_input
    mov rdi,cmd_about
    call str_equal
    test al,al
    jnz .about
    mov rsi,shell_input
    mov rdi,cmd_apps
    call str_equal
    test al,al
    jnz .apps
    mov rsi,shell_input
    mov rdi,cmd_env
    call str_equal
    test al,al
    jnz .env
    mov rsi,shell_input
    mov rdi,cmd_memory
    call str_equal
    test al,al
    jnz .memory
    mov rsi,shell_input
    mov rdi,cmd_reboot
    call str_equal
    test al,al
    jnz .reboot
    mov rsi,shell_input
    mov rdi,cmd_pip
    call str_equal
    test al,al
    jnz .pip
    mov rsi,shell_input
    mov rdi,cmd_game
    call str_equal
    test al,al
    jnz .game
    mov rsi,shell_input
    mov rdi,cmd_python
    call str_equal
    test al,al
    jnz .python
    mov rsi,shell_input
    mov rdi,cmd_python_version
    call str_equal
    test al,al
    jnz .python_version
    mov rsi,shell_input
    mov rdi,cmd_python_print
    call str_prefix
    test al,al
    jnz .python_print
    mov rsi,shell_input
    mov rdi,cmd_pip_version
    call str_equal
    test al,al
    jnz .pip_version
    mov rsi,shell_input
    mov rdi,cmd_pip_list
    call str_equal
    test al,al
    jnz .pip_list
    mov rsi,shell_input
    mov rdi,cmd_pip_install
    call str_prefix
    test al,al
    jnz .pip_install
    mov rsi,shell_input
    mov rdi,cmd_echo
    call str_prefix
    test al,al
    jnz .echo
    ; Copy the unknown-command message into the output buffer.
    mov rsi,cmd_unknown
    mov rdi,shell_result
    call str_copy
    ret
.help:
    mov rsi,txt_help
    jmp .set
.clear:
    mov rsi,empty_string
    jmp .set
.uname:
    mov rsi,txt_uname
    jmp .set
.pwd:
    mov rsi,txt_pwd
    jmp .set
.ls:
    mov rsi,txt_ls
    jmp .set
.whoami:
    mov rsi,txt_whoami
    jmp .set
.version:
    mov rsi,txt_version
    jmp .set
.hostname:
    mov rsi,txt_hostname
    jmp .set
.about:
    mov rsi,txt_about
    jmp .set
.apps:
    mov rsi,txt_apps
    jmp .set
.env:
    mov rsi,txt_env
    jmp .set
.memory:
    mov rsi,txt_memory
    jmp .set
.reboot:
    ; Restart the kernel and show the startup session chooser again.
    jmp kernel_entry
.game:
    call game_demo
    mov rsi,txt_game_exit
    jmp .set
.python:
    mov rsi,txt_python
    jmp .set
.python_version:
    mov rsi,txt_python_version
    jmp .set
.python_print:
    ; Tiny built-in Python subset: python print("text")
    ; Accepts a quoted string literal only; this is not CPython.
    mov rsi,shell_input
    add rsi,13
    cmp byte [rsi],34
    je .python_print_quoted
    cmp byte [rsi],39
    je .python_print_quoted
    mov rdi,shell_result
    call str_copy
    ret
.python_print_quoted:
    mov al,[rsi]
    mov [python_quote],al
    inc rsi
    mov rdi,shell_result
.python_print_loop:
    lodsb
    test al,al
    jz .python_print_done
    cmp al,[python_quote]
    je .python_print_done
    stosb
    jmp .python_print_loop
.python_print_done:
    mov byte [rdi],0
    ret
.pip:
    mov rsi,txt_pip
    jmp .set
.pip_version:
    mov rsi,txt_pip_version
    jmp .set
.pip_list:
    mov rsi,txt_pip_list
    jmp .set
.pip_install:
    mov rsi,txt_pip_install
    jmp .set
.echo:
    ; echo is accepted; print the remainder after "echo ".
    mov rsi,shell_input
    add rsi,5
    mov rdi,shell_result
    call str_copy
    ret
.set:
    mov rdi,shell_result
    call str_copy
    ret

; MiniPygame-style native demo: move a colored player block with arrow keys.
; This is a kernel demo, not Python or the Pygame library.
game_demo:
    mov dword [game_x],152
    mov rdi,0
    mov rsi,0
    mov rdx,320
    mov rcx,200
    mov r8d,1
    call rect
    mov rdi,8
    mov rsi,game_title
    mov edx,8
    mov ecx,15
    call text
    mov rdi,8
    mov rsi,game_instructions
    mov edx,28
    mov ecx,14
    call text
    mov rdi,0
    mov rsi,174
    mov rdx,320
    mov rcx,26
    mov r8d,2
    call rect
    mov edi,[game_x]
    mov esi,148
    mov edx,16
    mov ecx,16
    mov r8d,12
    call rect
.game_wait:
    in al,0x64
    test al,1
    jz .game_wait
    in al,0x60
    test al,0x80
    jnz .game_wait
    cmp al,0x01
    je .game_done
    cmp al,0x4B
    je .game_left
    cmp al,0x4D
    je .game_right
    jmp .game_wait
.game_left:
    mov edi,[game_x]
    cmp edi,4
    jbe .game_wait
    mov esi,148
    mov edx,16
    mov ecx,16
    mov r8d,1
    call rect
    sub dword [game_x],4
    jmp .game_redraw
.game_right:
    mov edi,[game_x]
    cmp edi,300
    jae .game_wait
    mov esi,148
    mov edx,16
    mov ecx,16
    mov r8d,1
    call rect
    add dword [game_x],4
.game_redraw:
    mov edi,[game_x]
    mov esi,148
    mov edx,16
    mov ecx,16
    mov r8d,12
    call rect
    jmp .game_wait
.game_done:
    ret

; str_equal: RSI=left, RDI=right, returns AL=1 if equal.
str_equal:
    push rbx
.eq_loop:
    mov al,[rsi]
    mov bl,[rdi]
    cmp al,bl
    jne .not_equal
    test al,al
    jz .equal
    inc rsi
    inc rdi
    jmp .eq_loop
.equal:
    mov al,1
    pop rbx
    ret
.not_equal:
    xor al,al
    pop rbx
    ret

; str_prefix: RSI=input, RDI=prefix, returns AL=1 on prefix match.
str_prefix:
    push rbx
.pre_loop:
    mov al,[rdi]
    test al,al
    jz .pre_yes
    cmp al,[rsi]
    jne .pre_no
    inc rsi
    inc rdi
    jmp .pre_loop
.pre_yes:
    mov al,1
    pop rbx
    ret
.pre_no:
    xor al,al
    pop rbx
    ret

str_copy:
    push rax
.copy_loop:
    lodsb
    stosb
    test al,al
    jnz .copy_loop
    pop rax
    ret

; Startup chooser: 1 launches the graphical desktop, 2 opens terminal.
boot_choice:
    mov rdi,0
    mov rsi,0
    mov rdx,320
    mov rcx,200
    mov r8d,1
    call rect
    mov rdi,24
    mov rsi,boot_title
    mov edx,30
    mov ecx,15
    call text
    mov rdi,24
    mov rsi,boot_gui
    mov edx,70
    mov ecx,14
    call text
    mov rdi,24
    mov rsi,boot_cli
    mov edx,92
    mov ecx,14
    call text
    mov rdi,24
    mov rsi,boot_hint
    mov edx,140
    mov ecx,7
    call text
.wait:
    in al,0x64
    test al,1
    jz .wait
    in al,0x60
    test al,0x80
    jnz .wait
    cmp al,0x02
    je .gui
    cmp al,0x03
    je .cli
    jmp .wait
.gui:
    mov al,1
    ret
.cli:
    mov al,2
    ret

; rect: RDI=x, RSI=y, RDX=width, RCX=height, R8D=color.
rect:
    push rbx
    push r12
    push r13
    push r14
    mov r14d,edi            ; Preserve x: RDI is reused by STOSB.
    mov r12d,esi            ; Current y.
    mov r13d,ecx            ; Remaining rows.
.row:
    mov eax,r12d
    imul eax,320
    add eax,r14d
    mov ebx,eax
    mov eax,r8d
    mov ecx,edx
    mov rdi,0xA0000
    add rdi,rbx
    rep stosb
    inc r12d
    dec r13d
    jnz .row
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

; text: RDI=x, RSI=string, EDX=y, ECX=color.
text:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12,rsi
    mov r13d,edi
    mov r14d,edx
    mov r15d,ecx
.char:
    movzx ebx,byte [r12]
    test bl,bl
    jz .done
    inc r12
    mov eax,ebx
    shl eax,4
    add eax,0x5000
    mov ebx,eax
    xor r9d,r9d
.glyph_row:
    mov r11b,[rbx+r9]
    xor r10d,r10d
.glyph_col:
    test r11b,0x80
    jz .skip_pixel
    mov eax,r14d
    add eax,r9d
    imul eax,320
    add eax,r13d
    add eax,r10d
    mov rdi,0xA0000
    add rdi,rax
    mov [rdi],r15b
.skip_pixel:
    shl r11b,1
    inc r10d
    cmp r10d,8
    jne .glyph_col
    inc r9d
    cmp r9d,16
    jne .glyph_row
    add r13d,8
    jmp .char
.done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

; app_window: RSI=title, RDI=x, EDX=y, ECX=color.
app_window:
    ; Preserve title pointer, then draw a simple window and title.
    push rsi
    mov edi,96
    mov esi,38
    mov edx,150
    mov ecx,100
    mov r8d,15
    call rect
    mov edi,100
    mov esi,42
    mov edx,142
    mov ecx,16
    mov r8d,1
    call rect
    pop rsi
    mov edi,104
    mov edx,42
    mov ecx,15
    call text
    mov rsi,app_hint
    mov edi,104
    mov edx,70
    mov ecx,4
    call text
    ret

serial_init:
    mov dx,0x3F9
    xor al,al
    out dx,al
    mov dx,0x3FB
    mov al,0x80
    out dx,al
    mov dx,0x3F8
    mov al,3
    out dx,al
    mov dx,0x3F9
    xor al,al
    out dx,al
    mov dx,0x3FB
    mov al,3
    out dx,al
    mov dx,0x3FA
    mov al,0xC7
    out dx,al
    mov dx,0x3FC
    mov al,0x0B
    out dx,al
    ret
serial_write:
    push rbx
.next:
    lodsb
    test al,al
    jz .done
    mov bl,al
.wait:
    mov dx,0x3FD
    in al,dx
    test al,0x20
    jz .wait
    mov dx,0x3F8
    mov al,bl
    out dx,al
    jmp .next
.done:
    pop rbx
    ret

boot_title db 'NNOOBOS - CHOOSE YOUR SESSION',0
boot_gui db '1  Graphical desktop (KDE-style)',0
boot_cli db '2  Command-line terminal',0
boot_hint db 'Press 1 or 2 on the keyboard to continue',0
shell_active db 0
shell_len db 0
shell_input rb 64
shell_result rb 96
terminal_title db 'NNOOBOS TERMINAL - Linux-like command shell',0
shell_prompt db 'nnoobos@os:~$ ',0
shell_hint db 'T: exit terminal | Enter: run command | Backspace: edit',0
cmd_help db 'help',0
cmd_clear db 'clear',0
cmd_uname db 'uname',0
cmd_pwd db 'pwd',0
cmd_ls db 'ls',0
cmd_whoami db 'whoami',0
cmd_version db 'version',0
cmd_hostname db 'hostname',0
cmd_about db 'about',0
cmd_apps db 'apps',0
cmd_env db 'env',0
cmd_memory db 'memory',0
cmd_reboot db 'reboot',0
cmd_game db 'game',0
cmd_python db 'python',0
cmd_python_version db 'python --version',0
cmd_python_print db 'python print(',0
python_quote db 34
cmd_pip db 'pip',0
cmd_pip_version db 'pip --version',0
cmd_pip_list db 'pip list',0
cmd_pip_install db 'pip install ',0
cmd_echo db 'echo ',0
cmd_unknown db 'Unknown command. Type help.',0
empty_string db 0
txt_help db 'help clear uname pwd ls whoami version hostname about apps env memory reboot game (MiniPygame demo: arrow keys, Esc exits) | python python --version python print("text") | pip pip --version pip list pip install NAME echo TEXT',0
txt_uname db 'Nnoobos x86_64 (experimental OS)',0
txt_pwd db '/',0
txt_ls db 'Desktop  Documents  Notes  Downloads',0
txt_whoami db 'user',0
txt_version db 'Nnoobos OS prototype 0.2 | x86_64',0
txt_hostname db 'nnoobos',0
txt_about db 'Nnoobos: experimental hobby OS, BIOS boot, x86-64, VGA desktop.',0
txt_apps db 'Available: Files, Notes, Calculator (prototype windows).',0
txt_env db 'HOME=/  USER=user  SHELL=nnoobos-sh',0
txt_memory db 'Memory map and allocator are not implemented yet.',0
txt_game_exit db 'MiniPygame demo closed.',0
game_title db 'MINIPYGAME DEMO - NNOOBOS',0
game_instructions db 'Move the red block with LEFT/RIGHT arrows; ESC exits.',0
game_x dd 152
txt_python db 'MiniPython 0.1: use python print("Hello"). Strings only; no CPython yet.',0
txt_python_version db 'Nnoobos MiniPython 0.1 (limited built-in interpreter)',0
txt_pip db 'pip is a stub; package installation is not available yet.',0
txt_pip_version db 'pip compatibility stub 0.1 (Python runtime unavailable)',0
txt_pip_list db 'No Python packages: Python runtime and package database are not implemented.',0
txt_pip_install db 'Cannot install packages yet: Nnoobos needs Python, filesystem, and network support.',0
; PS/2 set-1 scan-code to lowercase ASCII lookup table.
scan_ascii db 0,0,'1','2','3','4','5','6','7','8','9','0','-','=',0,0,'q','w','e','r','t','y','u','i','o','p','[',']',0,0,'a','s','d','f','g','h','j','k','l',';',39,'`',0,92,'z','x','c','v','b','n','m',',','.','/',0,'*',0,' '
kernel_banner db 'NNOOBOS x86-64 KERNEL - GRAPHICAL DESKTOP | Long mode: ACTIVE',13,10,0
desktop_title db 'NNOOBOS',0
brand_label db 'NNOOBOS DESKTOP',0
files_label db 'FILES',0
notes_label db 'NOTES',0
calc_label db 'CALC',0
ready_line db 'Welcome to Nnoobos!',0
help_line db 'Press S for Start menu; 1 Files, 2 Notes, 3 Calculator.',0
start_title db 'START MENU',0
start_items db '1 Files  2 Notes  3 Calculator',0
files_title db 'File Manager',0
notes_title db 'Notepad',0
calc_title db 'Calculator',0
app_hint db 'Prototype app window',0
