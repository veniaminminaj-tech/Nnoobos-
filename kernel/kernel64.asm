; Nnoobos experimental x86-64 kernel.
; Loaded at physical 0x10000; first 2 MiB are identity-mapped by stage2.
use64
org 0x10000

kernel_entry:
    cli
    cld
    mov rsp, 0x70000

    ; Clear VGA text memory and show kernel status.
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
    mov rdi, 0xB8120
    mov rsi, kernel_line3
    mov ah, 0x1F
    call vga_write
    mov rdi, 0xB8150
    mov rsi, kernel_line4
    mov ah, 0x1F
    call vga_write

.halt:
    hlt
    jmp .halt

; RDI = VGA destination, RSI = NUL-terminated string, AH = text attribute.
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

; NEX64 native executable header validator (loader groundwork).
; RSI points to a 24-byte header:
;   bytes 0..4 = "NEX64", byte 5 = version 1, byte 6 = arch 2 (x86-64),
;   byte 7 reserved, dword [RSI+8] = image_size, dword [RSI+12] = entry_offset,
;   qword [RSI+16] = reserved (must be zero).
; Returns EAX=0 if valid, EAX=1 if invalid.
; This only validates an in-memory header. No filesystem/program execution yet.
nex_validate_header:
    push rbx
    mov eax, 1
    cmp dword [rsi], 0x3638454E ; "NEX6" little-endian
    jne .invalid
    cmp byte [rsi+4], '4'
    jne .invalid
    cmp byte [rsi+5], 1
    jne .invalid
    cmp byte [rsi+6], 2
    jne .invalid
    cmp byte [rsi+7], 0
    jne .invalid
    mov ebx, [rsi+8]
    test ebx, ebx
    jz .invalid
    cmp ebx, 0x00100000
    ja .invalid
    mov edx, [rsi+12]
    cmp edx, ebx
    jae .invalid
    cmp qword [rsi+16], 0
    jne .invalid
    xor eax, eax
.invalid:
    pop rbx
    ret

kernel_banner db 'NNOOBOS x86-64 KERNEL', 0
kernel_line1  db 'Long mode: ACTIVE | VGA text output: ACTIVE', 0
kernel_line2  db 'Native executable format: NEX64 (header validator added)', 0
kernel_line3  db 'EXE loading is not active: filesystem and process API are next.', 0
kernel_line4  db 'Experimental build - reset the emulator to restart.', 0
