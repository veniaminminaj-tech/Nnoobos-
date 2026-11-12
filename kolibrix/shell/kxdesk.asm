; KolibriX 0.5 — hybrid desktop concept
; Visual direction: macOS menu bar + dock, Windows 11 taskbar/cards,
; and iOS-style app tiles. Native MENUET01 / KolibriOS x86 ABI.
; This is a shell preview, not a full compositor/window manager.
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
    mov ebx,22*65536+250
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
    mov ecx,0x00EAF4FF
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

    ; Deep gradient-like wallpaper built from native filled rectangles.
    movzx ebx,word [screen_w]
    movzx ecx,word [screen_h]
    mov edx,0x101A32
    mov eax,13
    int 0x40
    rect 0,34,800,105,0x17264A
    rect 0,139,800,100,0x182747
    rect 0,239,800,100,0x17243F
    rect 0,339,800,100,0x141F37
    rect 0,439,800,1,0x314768

    ; macOS-inspired translucent menu bar.
    rect 0,0,800,34,0x101827
    rect 0,33,800,1,0x3A5272
    rect 14,8,18,18,0x4A9BD5
    rect 18,12,10,10,0xEAF4FF
    txt 42,22,0x00FFFFFF,label_brand
    txt 138,22,0x00C5D8EE,label_menu_file
    txt 188,22,0x00C5D8EE,label_menu_edit
    txt 238,22,0x00C5D8EE,label_menu_view
    txt 288,22,0x00C5D8EE,label_menu_help
    txt 620,22,0x00B8DFFF,label_status
    txt 720,22,0x00FFFFFF,label_clock

    ; Welcome panel / Windows 11-style information widget.
    rect 34,58,732,82,0x203653
    rect 34,58,732,1,0x53769A
    rect 34,58,4,82,0x58A9E6
    txt 58,88,0x00FFFFFF,label_welcome
    txt 58,113,0x00C6D9ED,label_subtitle
    txt 648,88,0x008FD4FF,label_release
    txt 648,113,0x008FD4FF,label_native

    ; iOS-like app tiles: large, simple, touch-friendly hit areas.
    shortcut 2,36,166,166,112
    shortcut 3,218,166,166,112
    shortcut 4,400,166,166,112
    shortcut 5,582,166,166,112

    ; Files tile.
    rect 36,166,166,112,0x233B59
    rect 36,166,166,1,0x52769B
    rect 58,188,44,38,0x4A9BD5
    rect 64,195,32,25,0xDCEEFF
    rect 64,192,20,5,0xDCEEFF
    txt 58,253,0x00FFFFFF,label_files
    txt 58,269,0x00AFCBE7,label_files_sub

    ; Terminal tile.
    rect 218,166,166,112,0x263B55
    rect 218,166,166,1,0x52769B
    rect 240,188,44,38,0x245B6D
    txt 250,213,0x00C5F2F2,label_terminal_icon
    txt 240,253,0x00FFFFFF,label_terminal
    txt 240,269,0x00AFCBE7,label_terminal_sub

    ; Editor tile.
    rect 400,166,166,112,0x343653
    rect 400,166,166,1,0x746B9D
    rect 422,188,44,38,0x70669B
    rect 432,196,24,2,0xFFFFFF
    rect 432,203,24,2,0xFFFFFF
    rect 432,210,18,2,0xFFFFFF
    txt 422,253,0x00FFFFFF,label_codestudio
    txt 422,269,0x00C7BFEA,label_codestudio_sub

    ; Settings tile.
    rect 582,166,166,112,0x29483F
    rect 582,166,166,1,0x5C927D
    rect 604,188,44,38,0x3E795F
    rect 624,194,4,26,0xD7F4E5
    rect 613,205,26,4,0xD7F4E5
    txt 604,253,0x00FFFFFF,label_settings
    txt 604,269,0x00B9DEC9,label_settings_sub

    ; Secondary widgets, inspired by macOS desktop widgets.
    rect 36,302,350,116,0x1C2E49
    rect 36,302,350,1,0x466588
    txt 56,332,0x00FFFFFF,label_widget_title
    txt 56,360,0x00C8DDF0,label_widget_line1
    txt 56,385,0x008EB9E0,label_widget_line2

    rect 404,302,344,116,0x1C2E49
    rect 404,302,344,1,0x466588
    txt 424,332,0x00FFFFFF,label_system_title
    txt 424,360,0x00C8DDF0,label_system_line1
    txt 424,385,0x008EB9E0,label_system_line2

    ; Windows 11 centered taskbar + macOS-style dock surface.
    movzx ebx,word [screen_h]
    sub ebx,58
    shl ebx,16
    or ebx,58
    movzx ecx,word [screen_w]
    mov edx,0x17263A
    mov eax,13
    int 0x40
    movzx ebx,word [screen_w]
    movzx ecx,word [screen_h]
    sub ecx,58
    shl ecx,16
    or ecx,1
    mov edx,0x496582
    mov eax,13
    int 0x40

    ; Dock background, anchored to the bottom edge.
    movzx ecx,word [screen_h]
    sub ecx,58
    shl ecx,16
    or ecx,58
    mov ebx,244*65536+312
    mov edx,0x263D59
    mov eax,13
    int 0x40
    movzx ecx,word [screen_h]
    sub ecx,58
    shl ecx,16
    or ecx,1
    mov ebx,244*65536+312
    mov edx,0x6686A8
    mov eax,13
    int 0x40

    ; Five touch-friendly dock targets, calculated from screen height.
    movzx ecx,word [screen_h]
    sub ecx,51
    shl ecx,16
    or ecx,42
    mov ebx,258*65536+42
    mov edx,0x20000001
    xor esi,esi
    mov eax,8
    int 0x40
    mov ebx,312*65536+42
    mov edx,0x20000002
    mov eax,8
    int 0x40
    mov ebx,366*65536+42
    mov edx,0x20000003
    mov eax,8
    int 0x40
    mov ebx,420*65536+42
    mov edx,0x20000004
    mov eax,8
    int 0x40
    mov ebx,474*65536+42
    mov edx,0x20000005
    mov eax,8
    int 0x40

    ; Draw dock icon backgrounds at the same screen-relative position.
    movzx ecx,word [screen_h]
    sub ecx,51
    shl ecx,16
    or ecx,42
    mov ebx,258*65536+42
    mov edx,0x356B98
    mov eax,13
    int 0x40
    mov ebx,312*65536+42
    mov edx,0x245B6D
    mov eax,13
    int 0x40
    mov ebx,366*65536+42
    mov edx,0x70669B
    mov eax,13
    int 0x40
    mov ebx,420*65536+42
    mov edx,0x3E795F
    mov eax,13
    int 0x40
    mov ebx,474*65536+42
    mov edx,0x3D4E70
    mov eax,13
    int 0x40

    ; Short labels inside the dock icons.
    mov eax,4
    mov ebx,273*65536
    movzx edx,word [screen_h]
    sub edx,24
    or ebx,edx
    mov ecx,0x00FFFFFF
    mov edx,label_start_short
    int 0x40
    mov eax,4
    mov ebx,326*65536
    movzx edx,word [screen_h]
    sub edx,24
    or ebx,edx
    mov ecx,0x00FFFFFF
    mov edx,label_files_short
    int 0x40
    mov eax,4
    mov ebx,380*65536
    movzx edx,word [screen_h]
    sub edx,24
    or ebx,edx
    mov ecx,0x00FFFFFF
    mov edx,label_terminal_short
    int 0x40
    mov eax,4
    mov ebx,434*65536
    movzx edx,word [screen_h]
    sub edx,24
    or ebx,edx
    mov ecx,0x00FFFFFF
    mov edx,label_code_short
    int 0x40
    mov eax,4
    mov ebx,488*65536
    movzx edx,word [screen_h]
    sub edx,24
    or ebx,edx
    mov ecx,0x00FFFFFF
    mov edx,label_settings_short
    int 0x40

    cmp byte [menu_open],1
    jne redraw_done

    ; Compact centered Start / app launcher panel.
    movzx eax,word [screen_h]
    sub eax,370
    shl eax,16
    or eax,310
    mov ebx,22*65536+310
    mov ecx,eax
    mov edx,0x1D304B
    mov eax,13
    int 0x40
    movzx eax,word [screen_h]
    sub eax,370
    shl eax,16
    or eax,2
    mov ebx,22*65536+310
    mov ecx,eax
    mov edx,0x68A9D8
    mov eax,13
    int 0x40
    menu_text 42,338,label_menu_title
    menu_button 10,296
    menu_button 11,254
    menu_button 12,212
    menu_button 13,170
    menu_button 14,128
    menu_text 42,304,label_menu_files
    menu_text 42,262,label_menu_terminal
    menu_text 42,220,label_menu_codestudio
    menu_text 42,178,label_menu_settings
    menu_text 42,136,label_menu_games

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
    je run_codestudio
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
    mov esi,path_codestudio
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
path_codestudio db '/SYS/DEVELOP/CEDIT',0
path_settings db '/SYS/SETUP',0
path_games db '/SYS/ALLGAMES',0
label_brand db 'KolibriX',0
label_menu_file db 'File',0
label_menu_edit db 'Edit',0
label_menu_view db 'View',0
label_menu_help db 'Help',0
label_status db 'PREVIEW BUILD',0
label_clock db 'KX 0.5',0
label_release db '0.5 PREVIEW',0
label_welcome db 'A desktop that feels familiar.',0
label_subtitle db 'macOS-inspired menu bar  |  Windows 11 layout  |  iOS-like app tiles',0
label_native db 'NATIVE',0
label_files db 'Files',0
label_files_sub db 'Browse your system',0
label_terminal_icon db '>_',0
label_terminal db 'Terminal',0
label_terminal_sub db 'Run commands',0
label_codestudio db 'Code Studio',0
label_codestudio_sub db 'C / C++ / C# development',0
label_settings db 'Settings',0
label_settings_sub db 'Configure KolibriX',0
label_widget_title db 'Quick glance',0
label_widget_line1 db 'Your KolibriX desktop is ready.',0
label_widget_line2 db 'Choose an app tile or open the dock.',0
label_system_title db 'System foundation',0
label_system_line1 db 'KolibriOS x86 kernel and native ABI',0
label_system_line2 db 'Upstream drivers are used in this preview.',0
label_start_short db 'K',0
label_files_short db 'F',0
label_terminal_short db 'T',0
label_code_short db '</>',0
label_settings_short db 'S',0
label_menu_title db 'KOLIBRIX  /  APPS',0
label_menu_files db 'File Manager',0
label_menu_terminal db 'Terminal',0
label_menu_codestudio db 'Code Studio',0
label_menu_settings db 'System Settings',0
label_menu_games db 'Games',0
image_end:
memory_end:
