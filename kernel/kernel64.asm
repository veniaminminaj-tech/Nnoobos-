; NedohackOS experimental x86-64 kernel.
; Loaded at physical 0x10000; stage2 identity-maps the first 4 GiB.
; FASM syntax. First graphical milestone: VBE framebuffer desktop, no mouse yet.
use64
org 0x10000

kernel_entry:
    cli
    cld
    mov rsp, 0x70000

    call serial_init
    mov rsi, kernel_banner
    call serial_write
    mov rsi, serial_line1
    call serial_write

    cmp byte [0x508], 1
    jne text_fallback

    mov r10d, [0x500]       ; linear framebuffer physical address
    mov r9d, [0x504]        ; bytes per scan line
    test r10, r10
    jz text_fallback
    test r9d, r9d
    jz text_fallback

    call draw_desktop
    mov rsi, serial_graphics
    call serial_write
    jmp .halt

text_fallback:
    ; If VBE is unavailable, keep a readable VGA text diagnostic.
    mov rdi, 0xB8000
    mov ax, 0x1F20
    mov ecx, 2000
    rep stosw
    mov rdi, 0xB8000
    mov rsi, kernel_banner
    mov ah, 0x1F
    call vga_write
    mov rdi, 0xB80A0
    mov rsi, kernel_line1
    mov ah, 0x1E
    call vga_write
    mov rdi, 0xB80F0
    mov rsi, kernel_line2
    mov ah, 0x1F
    call vga_write
    mov rsi, serial_fallback
    call serial_write

.halt:
    hlt
    jmp .halt

; Draw a simple desktop directly into the 24-bit BGR VBE linear framebuffer.
draw_desktop:
    push rbx
    push r12
    push r13
    push r14
    push r15

    ; Base fill and layered blue/purple wallpaper bands.
    mov edi, 0
    mov esi, 0
    mov edx, 800
    mov ecx, 600
    mov r8d, 0x10142F
    call fill_rect

    mov edi, 0
    mov esi, 0
    mov edx, 800
    mov ecx, 210
    mov r8d, 0x15244B
    call fill_rect
    mov edi, 0
    mov esi, 210
    mov edx, 800
    mov ecx, 170
    mov r8d, 0x20265A
    call fill_rect
    mov edi, 0
    mov esi, 380
    mov edx, 800
    mov ecx, 168
    mov r8d, 0x101D3C
    call fill_rect

    ; Neon accent strips make the wallpaper recognizable without external assets.
    mov edi, 0
    mov esi, 80
    mov edx, 800
    mov ecx, 3
    mov r8d, 0x00D7FF
    call fill_rect
    mov edi, 0
    mov esi, 385
    mov edx, 800
    mov ecx, 2
    mov r8d, 0xA65CFF
    call fill_rect

    ; Desktop icons: eight tiles in two rows, with simple built-in glyphs.
    mov edi, 32
    mov esi, 54
    mov r8d, 0x2465A8
    call draw_icon
    mov edi, 112
    mov esi, 54
    mov r8d, 0xC18B35
    call draw_icon
    mov edi, 192
    mov esi, 54
    mov r8d, 0x3D9B89
    call draw_icon
    mov edi, 272
    mov esi, 54
    mov r8d, 0x7A55C7
    call draw_icon
    mov edi, 32
    mov esi, 144
    mov r8d, 0x2584C7
    call draw_icon
    mov edi, 112
    mov esi, 144
    mov r8d, 0x4D9D68
    call draw_icon
    mov edi, 192
    mov esi, 144
    mov r8d, 0xC27643
    call draw_icon
    mov edi, 272
    mov esi, 144
    mov r8d, 0x5279D6
    call draw_icon

    ; Center panel/window.
    mov edi, 366
    mov esi, 168
    mov edx, 390
    mov ecx, 248
    mov r8d, 0x10182D
    call fill_rect
    mov edi, 366
    mov esi, 168
    mov edx, 390
    mov ecx, 34
    mov r8d, 0x26365D
    call fill_rect
    mov edi, 384
    mov esi, 182
    mov edx, 12
    mov ecx, 12
    mov r8d, 0xFF647C
    call fill_rect
    mov edi, 402
    mov esi, 182
    mov edx, 12
    mov ecx, 12
    mov r8d, 0xFFD166
    call fill_rect
    mov edi, 420
    mov esi, 182
    mov edx, 12
    mov ecx, 12
    mov r8d, 0x67E8B5
    call fill_rect

    ; Three app tiles inside the panel.
    mov edi, 400
    mov esi, 236
    mov r8d, 0x2A72C5
    call draw_icon
    mov edi, 510
    mov esi, 236
    mov r8d, 0x42A68B
    call draw_icon
    mov edi, 620
    mov esi, 236
    mov r8d, 0x8A60D2
    call draw_icon

    ; Bottom taskbar and its cyan top edge.
    mov edi, 0
    mov esi, 548
    mov edx, 800
    mov ecx, 52
    mov r8d, 0x090D1B
    call fill_rect
    mov edi, 0
    mov esi, 548
    mov edx, 800
    mov ecx, 3
    mov r8d, 0x00D7FF
    call fill_rect
    mov edi, 20
    mov esi, 562
    mov edx, 34
    mov ecx, 30
    mov r8d, 0x263D6A
    call fill_rect
    mov edi, 28
    mov esi, 570
    mov edx, 18
    mov ecx, 14
    mov r8d, 0x00D7FF
    call fill_rect

    ; Dock indicators.
    mov edi, 92
    mov esi, 574
    mov edx, 34
    mov ecx, 18
    mov r8d, 0x2465A8
    call fill_rect
    mov edi, 142
    mov esi, 574
    mov edx, 34
    mov ecx, 18
    mov r8d, 0xC18B35
    call fill_rect
    mov edi, 192
    mov esi, 574
    mov edx, 34
    mov ecx, 18
    mov r8d, 0x3D9B89
    call fill_rect
    mov edi, 242
    mov esi, 574
    mov edx, 34
    mov ecx, 18
    mov r8d, 0x7A55C7
    call fill_rect

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

; Draw an icon tile at (EDI, ESI) using R8D as its accent color.
draw_icon:
    push r8
    push rdi
    push rsi
    push rdx
    push rcx
    mov edx, 54
    mov ecx, 54
    mov r8d, 0x1B2745
    call fill_rect
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    pop r8
    push r8
    push rdi
    push rsi
    push rdx
    push rcx
    add edi, 10
    add esi, 8
    mov edx, 34
    mov ecx, 30
    mov r8d, [rsp+32]
    call fill_rect
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    pop r8
    ret

; fill_rect(x=EDI,y=ESI,width=EDX,height=ECX,color=R8D RGB)
; Framebuffer is 24-bit BGR. R10=base, R9D=pitch.
fill_rect:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15
    mov r12d, edi
    mov r13d, esi
    mov r14d, edx
    mov r15d, ecx
    mov ebx, r8d
.row:
    mov rdi, r10
    mov eax, r13d
    imul eax, r9d
    add rdi, rax
    mov eax, r12d
    lea eax, [rax+rax*2]
    add rdi, rax
    mov ebp, r14d
.pixel:
    mov eax, ebx
    mov [rdi], al
    shr eax, 8
    mov [rdi+1], al
    shr eax, 8
    mov [rdi+2], al
    add rdi, 3
    dec ebp
    jnz .pixel
    inc r13d
    dec r15d
    jnz .row
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret

; COM1 serial output is used by the GitHub Actions QEMU smoke test.
serial_init:
    mov dx, 0x3F9
    xor al, al
    out dx, al
    mov dx, 0x3FB
    mov al, 0x80
    out dx, al
    mov dx, 0x3F8
    mov al, 0x03
    out dx, al
    mov dx, 0x3F9
    xor al, al
    out dx, al
    mov dx, 0x3FB
    mov al, 0x03
    out dx, al
    mov dx, 0x3FA
    mov al, 0xC7
    out dx, al
    mov dx, 0x3FC
    mov al, 0x0B
    out dx, al
    ret

serial_write:
    push rbx
.next:
    lodsb
    test al, al
    jz .done
    mov bl, al
.wait:
    mov dx, 0x3FD
    in al, dx
    test al, 0x20
    jz .wait
    mov dx, 0x3F8
    mov al, bl
    out dx, al
    jmp .next
.done:
    pop rbx
    ret

vga_write:
    push rax
    push rbx
    push rdi
    push rsi
    mov bl, ah
.next:
    lodsb
    test al, al
    jz .done
    mov ah, bl
    stosw
    jmp .next
.done:
    pop rsi
    pop rdi
    pop rbx
    pop rax
    ret

kernel_banner db 'NEDOHACKOS x86-64 KERNEL', 13, 10, 0
serial_line1 db 'Long mode: ACTIVE', 13, 10, 0
serial_graphics db 'GRAPHICAL DESKTOP: ACTIVE (VBE 800x600x24)', 13, 10, 0
serial_fallback db 'VBE unavailable; VGA text fallback active.', 13, 10, 0
kernel_line1 db 'NedohackOS kernel is running.', 0
kernel_line2 db 'VBE framebuffer unavailable; text fallback.', 0
