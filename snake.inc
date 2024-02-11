%ifndef SNAKE_INC
%define SNAKE_INC

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
    .head:
    .head.x: resd 1
    .head.y: resd 1
    .tail: resq 1
    .length: resd 1
    .size:
endstruc

struc Point
    .x: resd 1
    .y: resd 1
    .size:
endstruc

struc Board
    .renderer: resq 1
    .window: resq 1
    .width: resd 1
    .height: resd 1
    .direction:
    .direction.x: resd 1
    .direction.y: resd 1
    .food:
    .food.x: resd 1
    .food.y: resd 1
    .snake: resq Snake.size
    .score: resd 1
    .font:	resq 1
    .score_texture: resq 1
    .score_buffer: resb 16
    .size:
endstruc

    section .text
%define TTF_STYLE_NORMAL 0x00
%define TTF_HINTING_LIGHT_SUBPIXEL 0x4

;SDL Constants
%define SDL_INIT_VIDEO 0x000020
%define SDL_WINDOWPOS_CENTERED	0x2FFF0000
%define SDLK_RIGHT 0x4000004f
%define SDLK_LEFT 0x40000050
%define SDLK_DOWN 0x40000051
%define SDLK_UP 0x40000052
%define SDL_KEYDOWN	0x300
%define SDL_WINDOW_ALLOW_HIGIDPI 0x2000
%define SDL_QUIT 0x100

; GAME Constants 
%define BLOCK_SIZE 20
%define BLOCK_SIZE_SMALL 12
%define width 40
%define height 30
%define SNAKE_MAX_LENGTH width * height

%define BLUE 0x0000ffff
%define RED 0xff0000ff
%define GREEN 0x00ff00ff
%define PASTEL_BLUE 0xa7c7e7
%define PASTEL_GREEN 0x77dd77ff
%define PASTEL_YELLOW 0xb7b76bff
%define YELLOW 0xffff00ff

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
extern SDL_snprintf 
extern SDL_CreateTextureFromSurface
extern SDL_RenderCopy

; TTF
extern TTF_Init
extern TTF_OpenFont
extern TTF_Quit
extern TTF_CloseFont


extern TTF_SetFontStyle
extern TTF_SetFontHinting
extern TTF_RenderText_Blended


; C functions
extern puts
extern printf
extern srand
extern time
extern rand

%endif ; SNAKE_INC