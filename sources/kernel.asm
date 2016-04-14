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

init:


	call init_graphics ;initalise graphics mode and colours
	call restore_teletype;restore teletype restore
	call print_welcome_message;print welcome message
	call read_char;read a character
	;call restore_teletype
	call print_from_stack
	call read_coordinate
	
	call read_char
	call draw
	jmp init

; dimensions of the rectangle:
; width: 10 pixels
; height: 5 pixels



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

welcome db 'Hello world from the kernel!', 13, 10, 0
decision db 'Press any key to draw image !',13,10,0
char 	 db 'obcdef',13,10,0
coordinate_x db 0 ; x coordinate_x
coordinate_y db 50 ;y coordinate
  
delay:
	push cx ;save registers
	push dx
	push ax
	MOV     CX, 01h ;number of microseconds 186a0- 0.1 s
	MOV     DX, 86a0h
	MOV     AH, 86h ;wait  (interrupt 15)
	INT     15h		;interrupt 15
	pop ax ;restore registers
	pop dx
	pop cx
	ret
	
w equ 10
h equ 5



; set video mode 13h - 320x200

draw:   
	mov ah, 0
    mov al, 13h 
    int 10h


	; draw upper line:

		mov cx, coordinate_x+w  ; column
		mov dx, coordinate_y     ; row
		mov al, 15     ; white
	u1: mov ah, 0ch    ; put pixel
		int 10h
		call delay
		dec cx
		cmp cx, coordinate_x
		jae u1
	 
	; draw bottom line:

		mov cx, coordinate_x+w  ; column
		mov dx, coordinate_y+h   ; row
		mov al, 15     ; white
	u2: mov ah, 0ch    ; put pixel
		int 10h
		call delay
		dec cx
		cmp cx, coordinate_x
		ja u2
	 
	; draw left line:

		mov cx, coordinate_x    ; column
		mov dx, coordinate_y+h   ; row
		mov al, 15     ; white
	u3: mov ah, 0ch    ; put pixel
		int 10h
		call delay
		dec dx
		cmp dx, coordinate_y
		ja u3 
		
		
	; draw right line:

		mov cx, coordinate_x+w  ; column
		mov dx, coordinate_y+h   ; row
		mov al, 15     ; white
	u4: mov ah, 0ch    ; put pixel
		int 10h
		call delay
		dec dx
		cmp dx, coordinate_y
		ja u4     
	 

	; pause the screen for dos compatibility:

	;wait for keypress
	  mov ah,00
	  int 16h			
	  ret
	  
restore_teletype:
	MOV AH, 0x0E ;function nr
	MOV BH, 0x00 ;page
	MOV BL, 0x02 ;color
	ret
	
read_char:
	mov ah,00;read character
	int 16h	;wait for character
	pop bx
	push ax
	push bx
	ret
	
print_welcome_message:
	MOV SI, welcome ;move msg to SI-pointer
	CALL PrintString ;call function to print SI (msg)
	mov si,decision
	call PrintString
	ret

init_graphics:
	mov ah, 0x00 ;graphic mode
	mov al, 0x10 ; Graphics       320 x 200
	int 0x10; interrupt 10
	ret

print_from_stack:;al is number of characters
	pop bx
	pop ax
	push bx
	call restore_teletype
	int 10h
	ret
	
read_coordinate:;get 3 decimals
	call read_char
	pop ax
	mov bx,ax
	sub bx,48
	mul ax,0x64
	add coordinate_x,bx
	push ax
	call print_from_stack
	call read_char
	pop ax
	mov bx,ax
	sub bx,48
	mul bx,10
	add coordinate_x,bx
	push ax
	call print_from_stack
	call read_char
	pop ax
	mov bx,ax
	sub bx,48
	add coordinate_x,bx
	push ax
	call print_from_stack
	
	ret
	

