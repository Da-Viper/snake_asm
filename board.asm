%include "snake.inc"
        section .text
global  draw_food
global  init_snake
global  print_snake


; create the snake from the middle of the scren extending to the left
; rdi Board *
init_snake:
        push    rbp
        mov     rbp, rsp
        mov     eax, dword [rdi + Board.width]
        shr     eax, 1
        mov     dword [rdi + Board.snake + Snake.head.x], eax
        mov     edx, dword [rdi + Board.height]
        shr     edx, 1
        mov     dword [rdi + Board.snake + Snake.head.y], edx

        ; set the tail moving left 
        mov     ecx, 0
        .set_tail:
        cmp     ecx, 3
        je      .end_init_snake

        lea     r13, dword [rcx + Point.size]
        sub     edx, 1
        mov     dword [rdi + Board.snake + Snake.tail + (rcx * Point.size) + Point.x], eax
        mov     dword [rdi + Board.snake + Snake.tail + (rcx * Point.size) + Point.y], edx

        add     ecx, 1
        jmp     .set_tail
        .end_init_snake:

        mov     dword [rdi + Board.snake + Snake.length], ecx
        pop     rbp
        ret

; rdi Board *
print_snake:
        push    rbp
        mov     rbp, rsp
        ; get the length 
        mov     r14d, dword [ rdi + Board.snake + Snake.length]
        ; loop through it and print the tail
        mov     r12, rdi
        xor     r13, r13
        .loop:
        cmp     r14d, r13d
        je      .end_loop


        mov     rdi, print_snake_str
        mov     esi, dword [r12 + Board.snake + Snake.tail + (r13 * Point.size) + Point.x]
        mov     edx, dword [r12 + Board.snake + Snake.tail + (r13 * Point.size) + Point.y]
        xor     rcx, rcx
        call    printf

        add     r13d, 1
        jmp     .loop
        .end_loop:

        pop     rbp
        ret

; function to draw the food
; rdi: Board * 
; esi: block_size
draw_food:
        push    rbp
        mov     rbp, rsp
        sub     rsp, SDL_Rect.size

        mov     r12, rdi
        push    rsi

        mov     rdi, qword [r12 + Board.renderer]
        xor     esi, esi
        xor     edx, edx
        mov     ECX, 255
        mov     r8d, 0xff
        call    SDL_SetRenderDrawColor

        mov     r10d, dword [r12 + Board.food.x]
        mov     r11d, dword [r12 + Board.food.y]

        pop     rsi
        imul    r10d, esi
        imul    r11d, esi

        mov     dword [rsp + SDL_Rect.x], r10d
        mov     dword [rsp + SDL_Rect.y], r11d
        mov     [rsp + SDL_Rect.w], esi
        mov     [rsp + SDL_Rect.h], esi

        mov     rdi, qword [r12 + Board.renderer]
        lea     rsi, qword [rsp]
        ; call SDL_RenderDrawRect
        call    SDL_RenderFillRect

        ; mov     rdi, str_draw_point
        ; mov	esi, dword [ r12 + Board.food.x]
        ; mov	edx, dword [ r12 + Board.food.y]
        ; xor	ecx, ecx
        ; call	printf

        add     rsp, SDL_Rect.size
        pop     rbp
        ret


        section .rodata
print_snake_str:
        db      "(%d, %d),", 0xa