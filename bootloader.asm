[BITS 16]
[ORG 0x7c00]

jmp bootload ;sari la bootloader

hw db "Hello world from 16 bits mode!",0x00

;Print characters to the screen 
println:
    lodsb ;Load string 
    cmp al,0
    jz complete
    mov ah, 0xE  ; teletype output
	int 0x10
    jmp println ;
complete:
    call PrintNwL
	
;Prints empty new lines like '\n' in C/C++ 	
PrintNwL: 
    mov al, 0	; null terminator '\0'
    stosb       ; Store string 

    ;Adds a newline break '\n'
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10
    mov al, 0x0A 
    int 0x10
	ret

bootload:
   cli ;clear interrupt
   ;stack segments
   mov ax,cs              
   mov ds,ax   
   mov es,ax               
   mov ss,ax                
   sti ;enable interrupt

   ;Print the first characters  
   ;mov si,hw
   ;int 0x10
   mov si, hw
   call println



MOV DL, 0x0 ;drive 0 = floppy 1
MOV DH, 0x0 ;head (0=base)
MOV CH, 0x0 ;track/cylinder
MOV CL, 0x02 ;sector (1=bootloader, apparently sectors starts counting at 1 instead of 0)
MOV BX, 0x1000 ;place in RAM for kernel - I suppose randomly chosen on examples
MOV ES, BX ;place BX in pointer ES
MOV BX, 0x0 ;back to zero - also has something to do with RAM position

ReadFloppy:
MOV AH, 0x02
MOV AL, 0x01
INT 0x13
JC ReadFloppy ;if it went wrong, try again

;pointers to RAM position (0x1000)
MOV AX, 0x1000
MOV DS, AX
MOV ES, AX
MOV FS, AX
MOV GS, AX
MOV SS, AX

JMP 0x1000:0x00

;assuming we get never back here again, so no further coding needed (kernel handles everything now)
eob:;end of bootloader
TIMES 510 - ($ - $$) db 0 ;fill resting bytes with zero

DW 0xAA55 ;end of bootloader (2 bytes)

;start of kernel
sok:
;set print-registers

mov ah, 0x00 ;graphic mode
mov al, 0x10 ; Graphics       320 x 200
int 0x10; interrupt 10

MOV AH, 0x0E ;function nr
MOV BH, 0x00 ;page
MOV BL, 0x02 ;color

MOV SI, msg-sok ;move msg to SI-pointer
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

msg db 'Hello world from the kernel!', 13, 10, 0

TIMES 512 - ($ - sok) db 0 ;fill the rest
