; Nedohack DevTools — MenuetOS 64-bit / FASM starter
; This is a UI prototype, not a Python/C++ compiler or Windows EXE runner.
; Build only with a FASM version/toolchain compatible with MenuetOS 64-bit.
;
; MenuetOS syscall convention and header should be checked against the
; exact SDK/examples shipped with the MenuetOS version being targeted.

use64
org 0

db 'MENUET01'
dq 1                  ; version
dq start              ; entry point
dq image_end          ; image end
dq memory_end         ; required memory end
dq memory_end         ; stack
dq 0                  ; parameters
dq 0                  ; path

start:
redraw:
    mov rax, 0        ; draw window
    mov rbx, 100 shl 32 + 100
    mov rcx, 520 shl 32 + 330
    mov rdx, 0x14FFFFFF
    mov r8, 0
    int 0x60

    ; Window title
    mov rax, 4
    mov rbx, 120
    mov rcx, 120
    mov rdx, 0x00FFFFFF
    mov r8, title
    mov r9, title_len
    int 0x60

    ; Subtitle / honest capability note
    mov rax, 4
    mov rbx, 120
    mov rcx, 150
    mov rdx, 0x00D0D0D0
    mov r8, subtitle
    mov r9, subtitle_len
    int 0x60

    ; Section labels
    mov rax, 4
    mov rbx, 125
    mov rcx, 200
    mov rdx, 0x00FFFFFF
    mov r8, python_text
    mov r9, python_len
    int 0x60

    mov rax, 4
    mov rbx, 125
    mov rcx, 230
    mov rdx, 0x00FFFFFF
    mov r8, cpp_text
    mov r9, cpp_len
    int 0x60

    mov rax, 4
    mov rbx, 125
    mov rcx, 260
    mov rdx, 0x00FFFFFF
    mov r8, exe_text
    mov r9, exe_len
    int 0x60

wait_event:
    mov rax, 10        ; wait for event
    int 0x60
    cmp rax, 1         ; redraw
    je redraw
    cmp rax, 2         ; keyboard
    je keyboard_event
    cmp rax, 3         ; button
    je button_event
    jmp wait_event

keyboard_event:
    mov rax, 2         ; consume key event
    int 0x60
    jmp wait_event

button_event:
    mov rax, 17        ; consume button event
    int 0x60
    jmp wait_event

title db 'Nedohack DevTools'
title_len = $ - title
subtitle db 'Native MenuetOS 64-bit prototype'
subtitle_len = $ - subtitle
python_text db 'Python: view/edit .py files when file API is added'
python_len = $ - python_text
cpp_text db 'C/C++: view/edit .c/.cpp/.h files when file API is added'
cpp_len = $ - cpp_text
exe_text db 'EXE: inspect file only; Windows EXE is not native here'
exe_len = $ - exe_text

image_end:
rb 4096
memory_end:
