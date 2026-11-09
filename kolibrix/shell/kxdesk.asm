; KolibriX 0.5 native desktop shell
; FASM / KolibriOS MENUET01 ABI. Uses upstream system services.
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
    mov ebx,14*65536+236
    movzx ecx,word [screen_h]
    sub ecx,offset_y
    shl ecx,16
    or ecx,34
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
    mov ecx,0x00E8F0FF
    mov edx,s
    int 0x40
}

start:
    mov eax,14
    int 0x40
    mov ebx,eax
    shr ebx,16
    mov [screen_w],bx
    and eax,0xffff
    mov [screen_h],ax

    movzx ebx,word [screen_w]
    movzx ecx,word [screen_h]
    mov edx,0x21000000
    int 0x40

redraw:
    mov eax,12
    mov ebx,1
    int 0x40

    ; Deep navy desktop and subtle header.
    mov eax,13
    movzx ebx,word [screen_w]
    movzx ecx,word [screen_h]
    mov edx,0x101827
    int 0x40
    rect 0,0,800,48,0x18263A
    rect 0,48,800,1,0x29435F
    txt 22,30,0x00E8F0FF,label_brand
    txt 650,30,0x0089BFFF,label_release

    ; Desktop app cards.
    shortcut 2,24,78,158,112
    shortcut 3,196,78,158,112
    shortcut 4,368,78,158,112
    shortcut 5,540,78,158,112

    rect 24,78,158,112,0x1D3048
    rect 25,79,156,1,0x426080
    rect 42,96,38,34,0x315B7D
    rect 47,101,28,24,0xB8DFFF
    txt 42,151,0x00E8F0FF,label_files

    rect 196,78,158,112,0x1D3048
    rect 197,79,156,1,0x426080
    rect 214,96,38,34,0x244B5F
    rect 220,102,26,22,0x59B9C8
    txt 214,151,0x00E8F0FF,label_terminal

    rect 368,78,158,112,0x1D3048
    rect 369,79,156,1,0x426080
    rect 386,96,38,34,0x4A456A
    rect 392,102,26,22,0xC4B7FF
    txt 386,151,0x00E8F0FF,label_notepad

    rect 540,78,158,112,0x1D3048
    rect 541,79,156,1,0x426080
    rect 558,96,38,34,0x365B46
    rect 564,102,26,22,0x91D6A7
    txt 558,151,0x00E8F0FF,label_settings

    ; Welcome / system information panel.
    rect 24,218,674,112,0x17263A
    rect 24,218,674,1,0x35516E
    txt 44,250,0x00FFFFFF,label_welcome
    txt 44,276,0x00B8DFFF,label_subtitle
    txt 44,302,0x008FA8C8,label_native

    ; Bottom taskbar.
    movzx ebx,word [screen_h]
    sub ebx,48
    shl ebx,16
    or ebx,48
    movzx ecx,word [screen_w]
    mov edx,0x17263A
    mov eax,13
    int 0x40
    movzx ebx,word [screen_w]
    movzx ecx,word [screen_h]
    sub ecx,48
    shl ecx,16
    or ecx,1
    mov edx,0x35516E
    mov eax,13
    int 0x40

    ; Start button.
    mov eax,8
    mov ebx,12*65536+104
    movzx ecx,word [screen_h]
    sub ecx,42
    shl ecx,16
    or ecx,34
    mov edx,1
    mov esi,0x294B6A
    int 0x40
    txt 30,0,0x00FFFFFF,label_start

    ; Version label at the right.
    mov eax,4
    movzx ebx,word [screen_w]
    sub ebx,140
    shl ebx,16
    movzx ecx,word [screen_h]
    sub ecx,19
    or ebx,ecx
    mov ecx,0x00B8DFFF
    mov edx,label_version
    mov eax,4
    int 0x40

    cmp byte [menu_open],1
    jne redraw_done

    ; Start panel and entries.
    mov eax,13
    mov ebx,14*65536+254
    movzx ecx,word [screen_h]
    sub ecx,310
    shl ecx,16
    or ecx,292
    mov edx,0x1B2D43
    int 0x40
    rect 14,0,254,2,0x4D83AE
    menu_text 30,278,label_menu_title
    menu_button 10,242
    menu_button 11,204
    menu_button 12,166
    menu_button 13,128
    menu_button 14,90
    menu_text 30,250,label_menu_files
    menu_text 30,212,label_menu_terminal
    menu_text 30,174,label_menu_notepad
    menu_text 30,136,label_menu_settings
    menu_text 30,98,label_menu_games

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
    je run_settings
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
label_brand db 'KolibriX',0
label_release db '0.5 PREVIEW',0
label_version db 'KolibriX 0.5.0',0
label_start db 'Start',0
label_files db 'File Manager',0
label_terminal db 'Terminal',0
label_notepad db 'Text Editor',0
label_settings db 'Settings',0
label_welcome db 'Welcome to KolibriX 0.5',0
label_subtitle db 'A refreshed native desktop on the KolibriOS x86 foundation.',0
label_native db 'Native apps use the upstream KolibriOS ABI in this preview.',0
label_menu_title db 'KOLIBRIX  /  APPLICATIONS',0
label_menu_files db 'File Manager',0
label_menu_terminal db 'Terminal',0
label_menu_notepad db 'Text Editor',0
label_menu_settings db 'System Settings',0
label_menu_games db 'Games',0
image_end:
memory_end:
