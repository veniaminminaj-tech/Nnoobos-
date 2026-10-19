; Nnoobos kernel placeholder.
; The kernel will be assembled as a separate binary when the bootloader
; supports loading it from disk. Do not include this file in main.asm yet.

use32

kernel_entry:
    cli
.hang:
    hlt
    jmp .hang
