	section .bss
struc SDL_Rect
	.x: resd 1
	.y: resd 1
	.w: resd 1
	.h: resd 1
	.size:
endstruc

struc SDL_Color
	.r: resb 1
	.g: resb 1
	.b: resb 1
	.a: resb 1
	.size:
endstruc

struc SDL_Event
	.type: resd 1
	.space: resd 4
	.sym: resd 1
	.size:
endstruc

struc Snake
	.head.x: resd 1
	.head.y: resd 1
	.head.tail: resq 20
	.size:
endstruc

struc Board
	.renderer: resq 1
	.window: resq 1
	.snake: resq 21
	.width: resd 1
	.height: resd 1
	.food.x: resd 1
	.food.y: resd 1
	.score: resd 1
	.size:
endstruc

	section .text
extern SDL_Init
extern SDL_CreateWindow
extern SDL_CreateRenderer
extern SDL_SetRenderDrawColor
extern SDL_RenderClear
extern SDL_RenderPresent
extern SDL_RenderDrawRect
extern SDL_RenderFillRect
extern SDL_GetError
extern SDL_PollEvent
extern SDL_DestroyWindow
extern SDL_Delay
extern SDL_Quit


; C functions
extern puts
extern printf
extern srand
extern time
extern rand

global main
init_board:
	; init the window and renderer
	; set width and height
	mov	r10d, [width]
	mov	dword [rsp + Board.width], r10d
	mov	r11d, [height]
	mov	dword [rsp + Board.height], r11d

	; create window
	mov	eax, [BLOCK_SIZE]
	imul	r10d, eax ; scale by block size
	imul	r11d, eax

	mov	edi, window_title
	mov	esi, dword [SDL_WINDOWPOS_CENTERED]
	mov	edx, dword [SDL_WINDOWPOS_CENTERED]
	mov	ecx, r10d
	mov	r8d, r11d
	mov	r9d, 0
	call	SDL_CreateWindow
	mov 	qword [rsp + Board.window], rax ; store the window pointer
	cmp	rax, 0x0 ; check if it is nullptr
	je 	handle_error 

	; create renderer	
	mov	rdi, qword [rsp + Board.window]
	mov	rsi, -1
	mov	rdx, 0
	call	SDL_CreateRenderer
	mov	qword [rsp + Board.renderer], rax ; store the renderer pointer
	cmp	rax, 0x0
	je	handle_error 

	jmp 	main.init_board_end

update_game: 

	jmp	game_loop.render_present


main:
	push	rbp
	mov	rbp, rsp
	xor	rax, rax
	sub	rsp, 16; space for color
	sub	rsp, SDL_Rect.size ; space for the rect
	sub	rsp, 64 ; create stack space for SDL_Event(56)
	sub 	rsp, 192 ; space for the board

	; seed rand
	mov 	rdi, 0x0
	call 	time
	mov	rdi, rax
	call	srand

	; init SDL 
	mov	edi, [SDL_INIT_VIDEO]
	call	SDL_Init

	; init board
	jmp 	init_board
	.init_board_end: 


	; initalize SDL event struct
	mov 	qword [rsp + Board.size + 16 + 8], 0
	mov 	qword [rsp + Board.size + 16 + 16], 0
	mov 	qword [rsp + Board.size + 16 + 24], 0
	mov 	qword [rsp + Board.size + 16 + 32], 0
	mov 	qword [rsp + Board.size + 16 + 40], 0
	mov 	qword [rsp + Board.size + 16 + 48], 0
	mov 	qword [rsp + Board.size + 16 + 56], 0


game_loop:
	; set renderer color 
	mov	rdi, qword [rsp + Board.renderer] 
	xor	esi, esi
	xor 	edx, edx
	xor 	ecx, ecx
	mov 	r8d, 0xff
	call 	SDL_SetRenderDrawColor

	mov	rdi, qword [rsp + Board.renderer]
	call 	SDL_RenderClear

	jmp handle_events_loop
	.handle_events_loop_end:

	.render_present:

	lea	rdi, qword [rsp + Board] 
	call 	create_food

	lea	rdi, qword [rsp + Board] 
	mov	esi, [BLOCK_SIZE]
	call 	draw_food	

	mov 	rdi, 300
	call  	SDL_Delay

	mov	rdi, qword [rsp + Board.renderer]
	call 	SDL_RenderPresent
	jmp	game_loop
game_loop_end:

sdl_cleanup:
	mov	rdi, qword [rsp + Board.window]
	call	SDL_DestroyWindow
	call	SDL_Quit

main_function_end:
	xor	rax, rax
	add	rsp, 192
	add	rsp, 64
	add	rsp, SDL_Rect.size
	add	rsp, 16
	pop	rbp
	ret

handle_events_loop:
	lea	rdi, [rsp + Board.size + 16 + 8]
	call	SDL_PollEvent ; poll events
	cmp	eax, 0
	jz	game_loop.handle_events_loop_end

	mov	r10d, [rsp + Board.size + 16 + 8] 
	cmp	r10d, [SDL_QUIT] ; if quit is pressed
	je	game_loop_end

	; cmp	r10d, [SDL_KEYDOWN] 
	; je	handle_keypress	

	jmp	handle_events_loop


handle_error:
	call	SDL_GetError
	mov	rsi, rax
	mov	edi, str_error
	call	printf
	jmp	main_function_end

handle_keypress:
	mov 	r10d,[rsp + Board.size + 16 + 8 + SDL_Event.sym]
	cmp	r10d, [SDLK_UP]
	mov	eax, [RED]
	je	.set_colour
	cmp	r10d, [SDLK_DOWN]
	mov	eax, [GREEN]
	je	.set_colour
	cmp	r10d, [SDLK_LEFT]
	mov	eax, [BLUE]
	je	.set_colour
	cmp	r10d, [SDLK_RIGHT]
	mov	eax, [YELLOW]
	je	.set_colour
	mov	eax, 0x808080ff
	.set_colour:


; show_color:	
; 	mov	rdi, r13 ; renderer
; 	movzx	r8d, al ; a
; 	shr	rax, 8
; 	movzx	ecx, al ; b
; 	shr	rax, 8
; 	movzx	edx, al; r
; 	shr	rax, 8
; 	movzx	rsi, al; g
; 	call	SDL_SetRenderDrawColor
; 	jmp 	game_loop.render_present

; function to create the food from random numbers
; rdi: Board *
create_food: 
	push	rbp
	mov	rbp, rsp
	; compute rand from width and height then store it 
	; mov the board * 
	mov	r12, rdi

	call	rand
	xor	edx, edx
	mov 	ecx, dword [ r12 + Board.width]
	div	ecx
	mov 	dword [ r12 + Board.food.x], edx
	mov	r13d, edx

	call	rand
	xor	edx, edx
	mov 	ecx, dword [ r12 + Board.height]
	div	ecx
	mov 	dword [ r12 + Board.food.y], edx

	; mov   	rdi, str_create_point
	; mov	esi, dword [r12 + Board.food.x]
	; mov	edx, dword [r12 + Board.food.y]
	; xor	ecx, ecx
	; call	printf

	pop 	rbp
	ret 

; function to draw the food
; rdi: Board * 
; esi: block_size
draw_food:
	push	rbp
	mov	rbp, rsp
	sub 	rsp, SDL_Rect.size

	mov 	r12, rdi
	mov	r13d, esi

	mov	rdi, qword [r12 + Board.renderer] 
	xor	esi, esi
	xor 	edx, edx
	mov 	ecx, 255
	mov 	r8d, 0xff
	call 	SDL_SetRenderDrawColor

	mov 	r10d, dword [r12 + Board.food.x]
	mov 	r11d, dword [r12 + Board.food.y]

	mov	esi, r13d
	imul	r10d, esi
	imul	r11d, esi

	mov	dword [rsp + SDL_Rect.x], r10d
	mov	dword [rsp + SDL_Rect.y], r11d
	mov	[rsp + SDL_Rect.w], esi
	mov	[rsp + SDL_Rect.h], esi

	mov	rdi, qword [r12 + Board.renderer]
	lea	rsi, qword [rsp]
	; call	SDL_RenderDrawRect
	call	SDL_RenderFillRect

	; mov   	rdi, str_draw_point
	; mov	esi, dword [ r12 + Board.food.x]
	; mov	edx, dword [ r12 + Board.food.y]
	; xor	ecx, ecx
	; call	printf

	add	rsp, SDL_Rect.size
	pop	rbp
	ret

; Function to draw snake
; rdi: Board *
; esi: block_size
; draw_snake:
; 	push	rbp
; 	mov	rbp, rsp

; ---- [ SECTION RODATA ] ----
	section .rodata
;SDL Constants
SDL_INIT_VIDEO:	dd 0x000020
SDL_WINDOWPOS_CENTERED: dd 0x2FFF0000
SDL_QUIT: dd 0x100
SDLK_RIGHT: dd 0x4000004f
SDLK_LEFT: dd 0x40000050
SDLK_DOWN: dd 0x40000051
SDLK_UP: dd 0x40000052
SDL_KEYDOWN: dd 0x300

; GAME Constants
BLOCK_SIZE: dd 20
RED: dq 0xff0000ff
GREEN: dq 0x00ff00ff
BLUE: dq 0x0000ffff
YELLOW: dq 0xffff00ff
width: dd 40
height: dd 30
window_width: dd 800
window_height: dd 600
window_title: db "This is the assembly code", 0
hello: db "Hello world", 0xa, 0
str_error: db "Could not create sdl window: %s", 0xa, 0
str_create_point: db "Creating point at %d, %d", 0xa, 0
str_draw_point: db "Drawing point at %d, %d", 0xa, 0
