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
extern SDL_Quit
extern printf

global main
main:
	push	rbp
	mov	rbp, rsp
	xor	rax, rax
	sub	rsp, 16; space for color
	sub	rsp, SDL_Rect.size ; space for the rect
	sub	rsp, 64 ; create stack space for SDL_Event(56)

	; init SDL 
	mov	edi, [SDL_INIT_VIDEO]
	call	SDL_Init

	; create window
	mov	edi, window_title
	mov	esi, dword [SDL_WINDOWPOS_CENTERED]
	mov	edx, dword [SDL_WINDOWPOS_CENTERED]
	mov	ecx, dword [window_width]
	mov	r8d, dword [window_height]
	mov	r9d, 0
	call	SDL_CreateWindow
	mov	r12, rax ; store the window pointer
	cmp	r12, 0x0 ; check if it is nullptr
	je 	handle_error 

	; create renderer	
	xor	rdx, rdx
	mov	rdi, r12
	mov	rsi, -1
	mov	rdx, 0
	call	SDL_CreateRenderer
	mov	r13, rax ; store the renderer pointer
	cmp	r13, 0x0
	je	handle_error 

	mov 	rdi, r13
	call 	SDL_RenderClear

	; set renderer color 
	mov	rdi, r13 
	mov	esi, 0
	xor 	edx, edx
	mov 	ecx, 0xff
	mov 	r8d, 0xff
	call 	SDL_SetRenderDrawColor



	; delay for 5 seconds
	; mov rdi, 5000
	; call SDL_Delay

	; initalize SDL event struct
	mov 	qword [rsp + 8], 0
	mov 	qword [rsp + 16], 0
	mov 	qword [rsp + 24], 0
	mov 	qword [rsp + 32], 0
	mov 	qword [rsp + 40], 0
	mov 	qword [rsp + 48], 0
	mov 	qword [rsp + 56], 0

game_loop:
	lea	rdi, [rsp + 8]
	call	SDL_PollEvent ; poll events
	cmp	eax, 0
	jz	game_loop

	mov	r10d, [rsp + 8] 
	cmp	r10d, [SDL_QUIT] ; if quit is pressed
	je	game_loop_end

	cmp	r10d, [SDL_KEYDOWN] 
	je	handle_keypress	

render_present:
	
	mov	dword [rsp + 64 + SDL_Rect.x], 10
	mov	dword [rsp + 64 + SDL_Rect.y], 10
	mov	dword [rsp + 64 + SDL_Rect.w], 100
	mov	dword [rsp + 64 + SDL_Rect.h], 100
	mov	rdi, r13
	lea	rsi, [rsp + 64]
	call 	SDL_RenderFillRect

	mov 	rdi, r13
	call 	SDL_RenderPresent
	jmp	game_loop
game_loop_end:

sdl_cleanup:
	mov	rdi, r12
	call	SDL_DestroyWindow
	call	SDL_Quit

main_function_end:
	xor	rax, rax
	add	rsp, 64
	add	rsp, SDL_Rect.size
	add	rsp, 16
	leave
	ret

handle_error:
	call	SDL_GetError
	mov	rsi, rax
	mov	edi, str_error
	call	printf
	jmp	main_function_end

handle_keypress:
	mov 	r10d,[rsp + 8 + SDL_Event.sym]
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
	mov	eax, 0x111111ff
	.set_colour:


show_color:	
	mov	rdi, r13 ; renderer
	movzx	r8d, al ; a
	shr	rax, 8
	movzx	ecx, al ; b
	shr	rax, 8
	movzx	edx, al; r
	shr	rax, 8
	movzx	rsi, al; g
	call	SDL_SetRenderDrawColor
	jmp 	render_present


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

RED: dq 0xff0000ff
GREEN: dq 0x00ff00ff
BLUE: dq 0x0000ffff
YELLOW: dq 0xffff00ff
window_width: dd 800
window_height: dd 600
window_title: db "This is the assembly code", 0
hello: db "Hello world", 0xa, 0
str_error: db "Could not create sdl window: %s", 0xa, 0
