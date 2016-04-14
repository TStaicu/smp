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
	call print_walls
	hlt





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
coordinate_x db 0 	; x coordinate_x
coordinate_y db 50  ;y coordinate
len			 db 0
  
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



print_walls:
	;print top
	mov cx,1
	mov dx,1
	mov word [len],640
	call print_h_line
	;print left wall
	mov cx,1
	mov dx,1
	mov word [len],340
	call print_v_line
	;print right wall
	mov cx,637
	mov dx,1
	mov word [len],340
	call print_v_line
	
	ret
	

print_v_line:
	mov bx,dx        
	add bx,[len]
	prt_v: 
		mov al, 15      ; white
		mov ah, 0ch    ; put pixel
		int 10h
		;call delay
		inc dx
		cmp dx, bx
		jb prt_v
	ret
	ret

print_h_line: ;cx x_coordinate dx y coordinate len-length
	mov bx,cx        
	add bx,[len]
	prt_h: 
		mov al, 15      ; white
		mov ah, 0ch    ; put pixel
		int 10h
		;call delay
		inc cx
		cmp cx, bx
		jb prt_h
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
	imul ax,0x64
	add [coordinate_x],bx
	push ax
	call print_from_stack
	call read_char
	pop ax
	mov bx,ax
	mov cx,10
	sub bx,48
	imul bx,10
	add [coordinate_x],bx
	push ax
	call print_from_stack
	call read_char
	pop ax
	mov bx,ax
	sub bx,48
	add [coordinate_x],bx
	push ax
	call print_from_stack
	
	ret
	

