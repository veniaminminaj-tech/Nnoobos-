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
 mov eax,14
 int 0x40
 mov ebx,eax
 shr ebx,16
 mov ecx,eax
 and ecx,0xffff
 mov edx,0x40010000
 int 0x40
redraw:
 mov eax,12
 mov ebx,1
 int 0x40
 mov eax,13
 mov ebx,0
 mov ecx,0
 mov edx,0x008080
 int 0x40
 mov eax,12
 mov ebx,2
 int 0x40
event_loop:
 mov eax,10
 int 0x40
 cmp eax,1
 je redraw
 jmp event_loop
image_end:
memory_end:
