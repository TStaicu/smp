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
	mov dx,195
	call stdin_read
	mov cx,word [pallete_x]
	call draw_pallete_sprite
	call draw_ball_sprite
	call delay
	jmp init





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
len			 dw 0
ball_x dw 150
ball_y dw 100
pallete_x dw 0

  
delay:
	push cx ;save registers
	push dx
	push ax
	MOV     CX, 00h ;number of microseconds 186a0- 0.1 s
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
	mov al,0xf
	mov cx,1
	mov dx,1
	mov word [len],320
	call print_h_line
	;print left wall
	mov cx,1
	mov dx,1
	mov word [len],200
	call print_v_line
	;print right wall
	mov cx,318
	mov dx,1
	mov word [len],200
	call print_v_line
	
	ret
	

print_v_line:
	mov bx,dx        
	add bx,[len]
	prt_v: 
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
	mov al, 0x13 ; Graphics       320 x 200
	int 0x10; interrupt 10
	ret



	
draw_pallete_sprite:
	mov al,0xf
	push dx
	push cx
	mov word [len],64;pallete deffinition length
	call print_h_line
	pop cx
	pop dx ;restore ptrs
	push dx
	push cx
	dec dx
	call print_h_line
	pop cx
	pop dx ;restore ptrs
	push dx
	push cx
	dec dx
	call print_h_line
	pop cx
	pop dx ;restore ptrs
	push dx
	push cx
	dec dx
	call print_h_line
	pop cx
	pop dx ;restore ptrs
	push dx
	push cx
	dec dx
	call print_h_line
	pop cx
	pop dx ;restore ptrs
	push dx
	push cx
	dec dx
	call print_h_line
	pop cx
	pop dx ;restore ptrs
	push dx
	push cx
	dec dx
	call print_h_line
	pop cx
	pop dx
	ret

draw_ball_sprite:
	mov al,2
	mov cx,word [ball_x]
	mov dx,word [ball_y]
	
	dec dx
	push dx
	push cx
	mov word [len],10;pallete deffinition length
	call print_h_line
	pop cx
	pop dx
	dec dx
	push dx
	push cx
	call print_h_line
	pop cx
	pop dx
	dec dx
	push dx
	push cx
	call print_h_line
	pop cx
	pop dx
	dec dx
	push dx
	push cx
	call print_h_line
	pop cx
	pop dx
	dec dx
	push dx
	push cx
	call print_h_line
	pop cx
	pop dx
	dec dx
	push dx
	push cx
	call print_h_line
	pop cx
	pop dx
	dec dx
	push dx
	push cx
	call print_h_line
	pop cx
	pop dx
	dec dx
	push dx
	push cx
	call print_h_line
	pop cx
	pop dx
	dec dx
	push dx
	push cx
	call print_h_line
	pop cx
	pop dx
	dec dx
	push dx
	push cx
	call print_h_line
	pop cx
	pop dx
	ret

stdin_read:;check stdin buffer
	mov ah,0x01
	int 16h
	jnz sr
	ret

sr:;read from stdin buffer,and empty buffer (00h)
	mov ah,00h
	int 16h
	cmp ah,77
	je inc_plt
	cmp ah,75
	je dec_plt
	ret

inc_plt: ;increment pallete position
	mov ah,0
	int 21h
	cmp word [pallete_x],255
	ja rti
	add word [pallete_x],3
	rti:
	ret
	
dec_plt: ;decrement pallete position
	mov ah,0
	int 21h
	cmp word [pallete_x],3
	jb dc
	sub word [pallete_x],3
	dc:
	ret
	
