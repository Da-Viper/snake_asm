	section .text
extern SDL_Init
extern SDL_CreateWindow
extern SDL_CreateRenderer
extern SDL_SetRenderDrawColor
extern SDL_RenderClear
extern SDL_RenderPresent
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

    ; set renderer color 
	mov	rdi, r13 
	mov	rsi, 0
	xor 	rdx, rdx
	mov 	rcx, 0xff
	mov 	r8, 0xff
	call 	SDL_SetRenderDrawColor

	mov 	rdi, r13
	call 	SDL_RenderClear
	mov 	rdi, r13
	call 	SDL_RenderPresent

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

	mov	edi, [rsp + 8]
	cmp	edi, [SDL_QUIT]
	je	game_loop_end

	jmp	game_loop
game_loop_end:

sdl_cleanup:
	mov	rdi, r12
	call	SDL_DestroyWindow
	call	SDL_Quit
	jmp	main_function_end

handle_error:
	call	SDL_GetError
	mov	rsi, rax
	mov	edi, str_error
	call	printf

main_function_end:
	xor	rax, rax
	add	rsp, 64
	leave
	ret


; ---- [ SECTION RODATA ] ----
	section .rodata
;SDL Constants
SDL_INIT_VIDEO:	dd 0x000020
SDL_WINDOWPOS_CENTERED: dd 0x2FFF0000
SDL_QUIT: dd 0x100
window_width: dd 800
window_height: dd 600
window_title: db "This is the assembly code", 0
hello: db "Hello world", 0xa, 0
str_error: db "Could not create sdl window: %s", 0xa, 0
