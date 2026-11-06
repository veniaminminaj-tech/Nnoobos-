; KolibriX native test application
; Format: MENUET01 / KolibriOS native executable
; Build: fasm kxhello.asm KXHELLO.KEX

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
    mov eax, 0
    mov ebx, 360
    mov ecx, 180
    mov edx, 0x34FFFFFF
    mov esi, 0x00506078
    int 0x40

redraw:
    mov eax, 12
    mov ebx, 1
    int 0x40

    mov eax, 4
    mov ebx, 18*65536+18
    mov ecx, 0x00FFFFFF
    mov edx, title_text
    int 0x40

    mov eax, 4
    mov ebx, 18*65536+52
    mov ecx, 0x00B8DFFF
    mov edx, status_text
    int 0x40

    mov eax, 12
    mov ebx, 2
    int 0x40

event_loop:
    mov eax, 10
    int 0x40
    cmp eax, 1
    je redraw
    cmp eax, 2
    je key_event
    cmp eax, 3
    je button_event
    jmp event_loop

key_event:
    mov eax, 2
    int 0x40
    jmp event_loop

button_event:
    mov eax, 17
    int 0x40
    cmp al, 1
    je exit_app
    jmp event_loop

exit_app:
    mov eax, -1
    int 0x40

title_text db 'KolibriX system module test', 0
status_text db 'Native app loaded successfully.', 0

image_end:
memory_end:
