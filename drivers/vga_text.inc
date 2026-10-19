; Nnoobos VGA text-mode driver primitives (FASM, 16-bit real mode)
; 80x25 color text memory is at B800:0000 in the current BIOS mode.

vga_set_text_mode:
    mov ax, 0x0003
    int 0x10
    ret

; vga_putc: AL=character. Uses BIOS teletype output.
vga_putc:
    mov ah, 0x0E
    mov bh, 0
    int 0x10
    ret

; vga_clear_screen: clear via BIOS mode reset.
vga_clear_screen:
    mov ax, 0x0003
    int 0x10
    ret
