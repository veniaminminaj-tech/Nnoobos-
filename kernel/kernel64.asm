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
    mov rsi,8
    mov rdx,terminal_title
    mov ecx,10
    call text
    mov rdi,8
    mov rsi,35
    mov rdx,shell_result
    mov ecx,10
    call text
    mov rdi,8
    mov rsi,160
    mov rdx,shell_prompt
    mov ecx,10
    call text
    mov rdi,104
    mov rsi,shell_input
    mov edx,160
    mov ecx,15
    call text
    mov rdi,8
    mov rsi,185
    mov rdx,shell_hint
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
    mov rdi,cmd_echo
    call str_prefix
    test al,al
    jnz .echo
    mov rsi,cmd_unknown
    mov [shell_result],rsi
    ; Copy string contents, not its pointer.
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

; rect: RDI=x, RSI=y, RDX=width, RCX=height, R8D=color.
rect:
    push rbx
    push r12
    push r13
    mov r12d,esi
    mov r13d,ecx
.row:
    mov eax,r12d
    imul eax,320
    add eax,edi
    mov ebx,eax
    mov eax,r8d
    mov ecx,edx
    mov rdi,0xA0000
    add rdi,rbx
    rep stosb
    inc r12d
    dec r13d
    jnz .row
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

shell_active db 0
shell_len db 0
shell_input times 64 db 0
shell_result times 96 db 0
terminal_title db 'NNOOBOS TERMINAL - Linux-like command shell',0
shell_prompt db 'nnoobos@os:~$ ',0
shell_hint db 'T: exit terminal | Enter: run command | Backspace: edit',0
cmd_help db 'help',0
cmd_clear db 'clear',0
cmd_uname db 'uname',0
cmd_pwd db 'pwd',0
cmd_ls db 'ls',0
cmd_whoami db 'whoami',0
cmd_echo db 'echo ',0
cmd_unknown db 'Unknown command. Type help.',0
empty_string db 0
txt_help db 'help clear uname pwd ls whoami echo TEXT',0
txt_uname db 'Nnoobos x86_64 (experimental OS)',0
txt_pwd db '/',0
txt_ls db 'Desktop  Documents  Notes  Downloads',0
txt_whoami db 'user',0
; PS/2 set-1 scan-code to lowercase ASCII lookup table.
scan_ascii db 0,0,'1','2','3','4','5','6','7','8','9','0','-','=',0,0,'q','w','e','r','t','y','u','i','o','p','[',']',0,0,'a','s','d','f','g','h','j','k','l',';',39,'`',0,'\\','z','x','c','v','b','n','m',',','.','/',0,'*',0,' '
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
