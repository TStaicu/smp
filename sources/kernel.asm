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

call init_graphics ;initalise graphics mode and colours
init:


	mov al,0x00               
	call draw_ball_sprite 
	mov al,0x00
	mov dx,195
	mov cx,word [pallete_x]
	call draw_pallete_sprite
	mov al,0x9
	call print_walls
	mov dx,195
	call stdin_read
	mov cx,word [pallete_x]
	mov al,0xf
	call draw_pallete_sprite
	call calc_ball_position_x
	call calc_ball_position_y
	call collision_detect
	mov al,2
	call draw_ball_sprite
	call delay
	jmp init

;no man's land :)
hlt

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

;variable definition space 
lost db 'Congratulations! YOU LOST!',13,10,0
coordinate_x db 0 	; x coordinate_x
coordinate_y db 50  ;y coordinate
len			 dw 0
ball_x dw 50
ball_y dw 150
ball_x_speed dw 2
ball_y_speed dw 2
ball_x_speed_up dw 1
ball_x_speed_left dw 1
pallete_x dw 0
;end variable deffinition space

  
delay:
	push cx ;save registers
	push dx
	push ax
	MOV     CX, 00h ;number of microseconds 186a0- 0.1 s
	MOV     DX, 0xffff
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
	


init_graphics:
	mov ah, 0x00 ;graphic mode
	mov al, 0x13 ; Graphics       320 x 200
	int 0x10; interrupt 10
	ret

clr_scr:
	mov ah, 0x06
	mov al, 0
	int 10h
	ret

	
draw_pallete_sprite:
	
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

calc_ball_position_y:
	;up/down position calculation
	cmp word [ball_x_speed_up],1
	je inc_ball_up
	jne dec_ball_up
	yrt:
	ret
	
calc_ball_position_x:
	cmp word [ball_x_speed_left],1;left/right position calculation
	je dec_ball_left
	jne inc_ball_left
	xrt:
	ret
	
inc_ball_up:
	push ax
	mov ax,word [ball_y]
	sub ax,word [ball_y_speed]
	mov word [ball_y],ax
	pop ax
	jmp yrt

dec_ball_up:
	push ax
	mov ax,word [ball_y]
	add ax,word [ball_y_speed]
	mov word [ball_y],ax
	pop ax
	jmp yrt
	
inc_ball_left:
	push ax
	mov ax,word [ball_x]
	add ax,word [ball_x_speed]
	mov word [ball_x],ax
	pop ax
	jmp xrt

dec_ball_left:
	push ax
	mov ax,word [ball_x]
	sub ax,word [ball_x_speed]
	mov word [ball_x],ax
	pop ax
	jmp xrt
	
collision_detect:;collision detection system
	mov ax,word[ball_y]
	cmp ax,10 ;;collision with top wall
	jbe reverse_y_speed
	rev_y:
	mov ax,word[ball_x];;collision detect with right wall
	cmp ax,305
	jae reverse_x_speed_left
	rev_l:
	cmp ax,5
	jbe reverse_x_speed_right
	pcd: ;pallete collision detection	
	mov ax,word[ball_y]
	cmp ax,188
	jae bpcms ;ball pallete collision management system
	
	cdr:
	ret

reverse_y_speed:
	mov word[ball_x_speed_up],0
	jmp rev_y

reverse_x_speed_left:
	mov word[ball_x_speed_left],1
	jmp rev_l

reverse_x_speed_right:
	mov word[ball_x_speed_left],0
	jmp pcd
	
bpcms:
	mov ax,word[ball_x]
	mov bx,word[pallete_x];check right attributes(if the ball is in the right of pallete)
	add ax,10			 ;take into account the width of the ball
	cmp ax,bx
	jae bpcmsl   		;check left 
	jmp loose ;collision detection system return
	
bpcmsl:;check left hand attributes
	mov ax,word[ball_x]
	add bx,64
	cmp ax,bx
	jbe reverse_y_speed_pallete
	jmp loose

reverse_y_speed_pallete:
	mov word[ball_x_speed_up],1
	jmp cdr
	
loose:
	call restore_teletype
	mov si,lost
	call PrintString
	hlt
	

