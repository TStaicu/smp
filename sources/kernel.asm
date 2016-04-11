BITS 16

cli
mov	ax, 0x0000
mov	ss, ax
mov	sp, 0xFFFF
sti

mov	ax, 2000h
mov	ds, ax
mov	es, ax
mov	fs, ax
mov	gs, ax


mov ah, 0x00 ;graphic mode
mov al, 0x10 ; Graphics       320 x 200
int 0x10; interrupt 10


MOV AH, 0x0E ;function nr
MOV BH, 0x00 ;page
MOV BL, 0x02 ;color

MOV SI, msg ;move msg to SI-pointer
CALL PrintString ;call function to print SI (msg)

JMP $ ;hang

PrintString:
.next_char:
MOV AL, [SI] ;current character
OR AL, AL
JZ .exit_char;if current char is zero, go to end
INT 0x10 ;print character
INC SI ;increase pointer to msg (next character)
JMP .next_char
.exit_char:
RET

msg db 'Hello world from the kernel :))!', 13, 10, 0