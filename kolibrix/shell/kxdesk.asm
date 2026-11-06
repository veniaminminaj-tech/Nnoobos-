; KolibriX 98 native graphical desktop
; Built with FASM for the official KolibriOS x86 system.
use32
org 0
db 'MENUET01'
dd 1
dd start
dd image_end
dd memory_end
dd memory_end
dd 0
dd 0

start:
    mov eax,14
    int 0x40
    mov ebx,eax
    shr ebx,16
    mov [screen_w],bx
    and eax,0xffff
    mov [screen_h],ax

    ; Full-screen borderless client window.
    movzx ebx,word [screen_w]
    movzx ecx,word [screen_h]
    mov edx,0x21000000
    int 0x40

redraw:
    mov eax,12
    mov ebx,1
    int 0x40

    ; Teal desktop.
    mov eax,13
    movzx ebx,word [screen_w]
    movzx ecx,word [screen_h]
    mov edx,0x008080
    int 0x40

    ; Grey taskbar, anchored to the bottom edge.
    movzx ebx,word [screen_w]
    mov ecx,word [screen_h]
    sub ecx,30
    shl ecx,16
    or ecx,30
    mov edx,0xc0c0c0
    mov eax,13
    int 0x40

    ; Classic raised Start button.
    mov eax,8
    mov ebx,5*65536+72
    movzx ecx,word [screen_h]
    sub ecx,26
    shl ecx,16
    or ecx,21
    mov edx,1
    mov esi,0xc0c0c0
    int 0x40

    ; Invisible clickable shortcut areas.
    shortcut 2,16,20,100,82
    shortcut 3,16,120,100,82
    shortcut 4,16,220,100,82
    shortcut 5,16,320,100,82

    ; Start menu hit areas.
    menu_button 10,238
    menu_button 11,204
    menu_button 12,170
    menu_button 13,136
    menu_button 14,102

    ; Desktop icons.
    rect 25,28,34,28,0xffffff
    rect 28,31,28,21,0x000080
    txt 16,65,0xffffff,label_computer

    rect 25,128,34,28,0xffffff
    rect 28,132,28,20,0xe0b040
    txt 16,165,0xffffff,label_files

    rect 25,228,34,28,0xffffff
    rect 28,232,28,20,0x204080
    txt 16,265,0xffffff,label_terminal

    rect 25,328,34,28,0xffffff
    rect 28,332,28,20,0xffffff
    txt 16,365,0xffffff,label_notepad

    txt 16,8,0xffffff,label_brand

    ; Start button caption and taskbar branding.
    mov eax,4
    mov ebx,15*65536
    movzx edx,word [screen_h]
    sub edx,19
    add ebx,edx
    mov ecx,0
    mov edx,label_start
    int 0x40

    mov eax,4
    movzx ebx,word [screen_w]
    sub ebx,116
    shl ebx,16
    movzx eax,word [screen_h]
    sub eax,19
    or ebx,eax
    mov ecx,0
    mov edx,label_version
    mov eax,4
    int 0x40

    cmp byte [menu_open],1
    jne redraw_done

    ; Raised Start menu panel.
    mov eax,13
    mov ebx,224
    movzx ecx,word [screen_h]
    sub ecx,250
    shl ecx,16
    or ecx,220
    mov edx,0xc0c0c0
    int 0x40

    ; Blue vertical banner.
    mov eax,13
    mov ebx,5*65536+28
    movzx ecx,word [screen_h]
    sub ecx,245
    shl ecx,16
    or ecx,210
    mov edx,0x000080
    int 0x40

    ; Start menu items.
    menu_text 22,228,label_menu_files
    menu_text 22,194,label_menu_terminal
    menu_text 22,160,label_menu_notepad
    menu_text 22,126,label_menu_settings
    menu_text 22,92,label_menu_games
    menu_text 9,70,label_menu_brand

redraw_done:
    mov eax,12
    mov ebx,2
    int 0x40

event_loop:
    mov eax,10
    int 0x40
    cmp eax,1
    je redraw
    cmp eax,2
    je key_event
    cmp eax,3
    je button_event
    jmp event_loop

key_event:
    mov eax,2
    int 0x40
    jmp event_loop

button_event:
    mov eax,17
    int 0x40
    shr eax,8
    cmp eax,1
    je toggle_menu
    cmp eax,2
    je run_files
    cmp eax,3
    je run_terminal
    cmp eax,4
    je run_notepad
    cmp eax,5
    je run_games
    cmp byte [menu_open],1
    jne event_loop
    cmp eax,10
    je run_files
    cmp eax,11
    je run_terminal
    cmp eax,12
    je run_notepad
    cmp eax,13
    je run_settings
    cmp eax,14
    je run_games
    jmp event_loop

toggle_menu:
    xor byte [menu_open],1
    jmp redraw

run_files:
    mov esi,path_files
    call launch_app
    jmp close_menu
run_terminal:
    mov esi,path_terminal
    call launch_app
    jmp close_menu
run_notepad:
    mov esi,path_notepad
    call launch_app
    jmp close_menu
run_settings:
    mov esi,path_settings
    call launch_app
    jmp close_menu
run_games:
    mov esi,path_games
    call launch_app
close_menu:
    mov byte [menu_open],0
    jmp redraw

launch_app:
    mov dword [run_info],7
    mov dword [run_info+4],0
    mov dword [run_info+8],0
    mov dword [run_info+12],0
    mov dword [run_info+16],0
    mov dword [run_info+20],esi
    mov eax,70
    mov ebx,run_info
    int 0x40
    ret

macro rect x,y,w,h,c
{
    mov eax,13
    mov ebx,(x shl 16)+w
    mov ecx,(y shl 16)+h
    mov edx,c
    int 0x40
}
macro txt x,y,c,s
{
    mov eax,4
    mov ebx,(x shl 16)+y
    mov ecx,c
    mov edx,s
    int 0x40
}
macro shortcut id,x,y,w,h
{
    mov eax,8
    mov ebx,(x shl 16)+w
    mov ecx,(y shl 16)+h
    mov edx,0x20000000+id
    xor esi,esi
    int 0x40
}
macro menu_button id,offset_y
{
    mov eax,8
    mov ebx,12*65536+198
    movzx ecx,word [screen_h]
    sub ecx,offset_y
    shl ecx,16
    or ecx,30
    mov edx,0x20000000+id
    xor esi,esi
    int 0x40
}
macro menu_text x,offset_y,s
{
    mov eax,4
    mov ebx,x*65536
    movzx ecx,word [screen_h]
    sub ecx,offset_y
    or ebx,ecx
    mov ecx,0
    mov edx,s
    int 0x40
}

screen_w dw 800
screen_h dw 600
menu_open db 0
align 4
run_info dd 7,0,0,0,0,0
path_files db '/SYS/FILE MANAGERS/EOLITE',0
path_terminal db '/SYS/TERMINAL',0
path_notepad db '/SYS/TINYPAD',0
path_settings db '/SYS/SETUP',0
path_games db '/SYS/ALLGAMES',0
label_brand db 'KolibriX 98',0
label_version db 'KolibriX 0.2',0
label_start db 'Start',0
label_computer db 'My Computer',0
label_files db 'Files',0
label_terminal db 'Terminal',0
label_notepad db 'Notepad',0
label_menu_brand db 'KolibriX 98',0
label_menu_files db 'File Manager',0
label_menu_terminal db 'Terminal',0
label_menu_notepad db 'Notepad',0
label_menu_settings db 'Settings',0
label_menu_games db 'Games',0
image_end:
memory_end:
