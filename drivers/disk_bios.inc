; Nnoobos BIOS disk driver primitive (FASM, 16-bit real mode)
; Reads sectors using INT 13h CHS. Caller supplies:
; AL=count, CH=cylinder, CL=sector (1-based), DH=head, DL=BIOS drive,
; ES:BX=destination. Carry flag indicates failure.
; Keep reads within track boundaries for broad BIOS compatibility.

disk_read_chs:
    mov ah, 0x02
    int 0x13
    ret

disk_reset:
    mov ah, 0x00
    int 0x13
    ret
