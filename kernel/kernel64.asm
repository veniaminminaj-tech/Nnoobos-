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
    ; Non-blocking PS/2 keyboard polling.
    in al,0x64
    test al,1
    jz .loop
    in al,0x60
    cmp al,0x1F
    je .start
    cmp al,0x02
    je .files
    cmp al,0x03
    je .notes
    cmp al,0x04
    je .calc
    cmp al,0x0B
    je .desktop
    jmp .loop
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
