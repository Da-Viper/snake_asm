%include "snake.inc"

        section .text
extern  create_food
extern  draw_food
extern  draw_block
extern  draw_snake
extern  init_snake
extern  print_snake
extern  set_direction
extern  update_food
extern  update_snake


global  main
init_board:
	; init the window and renderer
	; set width and height
        mov     r10d, [width]
        mov     dword [rsp + Board.width], r10d
        mov     r11d, [height]
        mov     dword [rsp + Board.height], r11d

	; create window
        mov     eax, [BLOCK_SIZE]
        imul    r10d, eax ; scale by block size
        imul    r11d, eax

        mov     edi, window_title
        mov     esi, dword [SDL_WINDOWPOS_CENTERED]
        mov     edx, dword [SDL_WINDOWPOS_CENTERED]
        mov     ecx, r10d
        mov     r8d, r11d
        mov     r9d, 0
        call    SDL_CreateWindow
        mov     qword [rsp + Board.window], rax ; store the window pointer
        cmp     rax, 0x0 ; check if it is nullptr
        je      handle_error

        ; create renderer	
        mov     rdi, qword [rsp + Board.window]
        mov     esi, -1
        mov     edx, 0
        call    SDL_CreateRenderer
        mov     qword [rsp + Board.renderer], rax ; store the renderer pointer
        cmp     rax, 0x0
        je      handle_error

        ; set direction right
        ; mov     dword [rsp + Board.direction.x], 1
        ; mov     dword [rsp + Board.direction.y], 0
        lea     rdi, [rsp + Board]
        mov     esi, 4
        call    set_direction

        ; set score
        mov     dword [rsp + Board.score], 0
        
        ; init score font
        mov     rdi, DEFAULT_FONT
        mov     esi, dword [FONT_SIZE]
        call    TTF_OpenFont
        cmp     rax, 0x0
        je      handle_error
        mov     qword [rsp + Board.font], rax 

        mov     rdi, qword [rsp + Board.font]
        mov     esi, TTF_STYLE_NORMAL
        call    TTF_SetFontStyle

        mov     rdi, qword [rsp + Board.font]
        mov     esi, TTF_HINTING_LIGHT_SUBPIXEL
        call    TTF_SetFontHinting


        ; create the text surface
        ; format the string
        lea     rdi, qword [rsp + Board.score_buffer]
        mov     rsi, 16
        mov     rdx, score_text 
        mov     rcx, qword [rsp + Board.score]
        call    SDL_snprintf

        mov     rdi, qword [rsp + Board.font]
        mov     rsi, score_text
        mov     edx, 0xffffffff
        call    TTF_RenderText_Blended

        mov     rdi, qword [rsp + Board.renderer]
        mov     rsi, rax
        call    SDL_CreateTextureFromSurface
        mov     qword [rsp + Board.score_texture], rax
        jmp     main.init_board_end

update_game:

        jmp     game_loop.render_present


main:
        push    rbp
        mov     rbp, rsp
        xor     rax, rax
        sub     rsp, 16; space for color
        sub     rsp, SDL_Rect.size ; space for the rect
        sub     rsp, 64 ; create stack space for SDL_Event(56)
        sub     rsp, 784 ; space for the board
 

	; seed rand
        mov     rdi, 0x0
        call    time
        mov     rdi, rax
        call    srand

	; init SDL 
        mov     edi, [SDL_INIT_VIDEO]
        call    SDL_Init

        ; init TTF
        call    TTF_Init
        test    eax, eax
        jl      handle_error 

	; init board
        jmp     init_board
        .init_board_end:


	; initalize SDL event struct
        mov     qword [rsp + Board.size + 8], 0
        mov     qword [rsp + Board.size + 16], 0
        mov     qword [rsp + Board.size + 24], 0
        mov     qword [rsp + Board.size + 32], 0
        mov     qword [rsp + Board.size + 40], 0
        mov     qword [rsp + Board.size + 48], 0
        mov     qword [rsp + Board.size + 56], 0

        lea     rdi, qword [rsp + Board]
        call    init_snake

        lea     rdi, qword [rsp + Board]
        call    create_food

        lea     rdi, qword [rsp + Board]
        call    print_snake

game_loop:
	; set renderer color 
        mov     rdi, qword [rsp + Board.renderer]
        xor     esi, esi
        xor     edx, edx
        xor     ecx, ecx
        mov     r8d, 0xff
        call    SDL_SetRenderDrawColor

        mov     rdi, qword [rsp + Board.renderer]
        call    SDL_RenderClear

        jmp     handle_events_loop
        .handle_events_loop_end:

        .render_present:

        lea     rdi, [rsp + Board]
        call    update_state

        ; show score
        mov     rdi, qword [rsp + Board.renderer] 
        mov     rsi, qword [rsp + Board.score_texture]
        mov     dword [rsp + 800 + SDL_Rect.x], 10
        mov     dword [rsp + 800 +SDL_Rect.y], 10
        mov     dword [rsp + 800 + SDL_Rect.w], 101
        mov     dword [rsp + 800 + SDL_Rect.h], 30
        mov     rdx, 0x0
        lea     rcx, [rsp + 800]
        call    SDL_RenderCopy

        mov     rdi, 100
        call    SDL_Delay

        mov     rdi, qword [rsp + Board.renderer]
        call    SDL_RenderPresent
        jmp     game_loop
game_loop_end:

sdl_cleanup:
        mov     rdi, qword [rsp + Board.font]
        call    TTF_CloseFont
        call    TTF_Quit
        mov     rdi, qword [rsp + Board.window]
        call    SDL_DestroyWindow
        call    SDL_Quit

main_function_end:
        xor     rax, rax
        add     rsp, 784
        add     rsp, 64
        add     rsp, SDL_Rect.size
        add     rsp, 16
        pop     rbp
        ret

handle_events_loop:
        lea     rdi, [rsp + Board.size + 8]
        call    SDL_PollEvent ; poll events
        cmp     eax, 0
        jz      game_loop.handle_events_loop_end

        mov     r10d, [rsp + Board.size + 8]
        cmp     r10d, [SDL_QUIT] ; if quit is pressed
        je      sdl_cleanup

	cmp	r10d, [SDL_KEYDOWN] 
	je	handle_keypress	

        jmp     handle_events_loop


handle_error:
        call    SDL_GetError
        mov     rsi, rax
        mov     edi, str_error
        call    printf
        jmp     main_function_end

handle_keypress:
        mov     r10d, [rsp + Board.size + 8 + SDL_Event.sym]
        cmp     r10d, [SDLK_UP]
        mov     eax, 1
        je      .end
        cmp     r10d, [SDLK_DOWN]
        mov     eax, 2
        je      .end
        cmp     r10d, [SDLK_LEFT]
        mov     eax, 3
        je      .end
        cmp     r10d, [SDLK_RIGHT]
        mov     eax, 4
        je      .end
        mov     eax, 0
        .end:

        lea     rdi, [rsp + Board]
        mov     esi, eax
        call    set_direction
	jmp 	game_loop.render_present

; rdi Board *
update_state:
        push    rbp
        mov     rbp, rsp
        push    r12
        mov     r12, rdi

        ; check collision
        ; collides with the walls 
        ; collides with itself

        ; update snake
        lea     rdi, [r12 + Board]
        call    update_snake

        ; update food 
        lea     rdi, [r12 + Board]
        call    update_food




        ; draw food
        mov     rdi, qword [r12 + Board.renderer]
        mov     rsi, [r12 + Board.food]
        mov     edx, [BLOCK_SIZE]
        mov     ecx, 0x0000ffff
        call    draw_block

        ; draw snake 
        lea     rdi, [r12 + Board]
        call    draw_snake

        pop     r12

        leave
        ret

; ---- [ SECTION RODATA ] ----
        section .rodata
;SDL Constants
SDL_INIT_VIDEO:
        dd      0x000020
SDL_WINDOWPOS_CENTERED:
        dd      0x2FFF0000
SDL_QUIT:
        dd      0x100
SDLK_RIGHT:
        dd      0x4000004f
SDLK_LEFT:
        dd      0x40000050
SDLK_DOWN:
        dd      0x40000051
SDLK_UP:
        dd      0x40000052
SDL_KEYDOWN:
        dd      0x300
SDL_WINDOW_ALLOW_HIGIDPI:
        dd      0x2000

; GAME Constants
BLOCK_SIZE:
        dd      20
RED:    dq      0xff0000ff
GREEN:  dq      0x00ff00ff
BLUE:   dq      0x0000ffff
YELLOW: dq      0xffff00ff
width:  dd      40
height: dd      30
window_width:
        dd      800
window_height:
        dd      600
DEFAULT_FONT:
        db      "font.ttf", 0
FONT_SIZE:
        dd      33
score_text: 
        dd      "Score: %d"
window_title:
        db      "This is the assembly code", 0
hello:  db      "Hello world", 0xa, 0
str_error:
        db      "SDL Error: %s", 0xa, 0
str_create_point:
        db      "Creating point at %d, %d", 0xa, 0
str_draw_point:
        db      "Drawing point at %d, %d", 0xa, 0

