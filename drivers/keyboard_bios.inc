; Nnoobos keyboard driver primitives (FASM, 16-bit real mode)
; BIOS-backed starter driver. Include from stage2 only after checking symbol names.
; int 16h AH=00h waits for a key; returns scan code in AH, ASCII in AL.

keyboard_read:
    xor ah, ah
    int 0x16
    ret

keyboard_check:
    mov ah, 0x01
    int 0x16
    jz .no_key
    mov al, 1
    ret
.no_key:
    xor al, al
    ret
