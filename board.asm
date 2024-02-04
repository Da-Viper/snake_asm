%include "snake.inc"
        section .text
global  draw_food
global  draw_block
global  draw_snake
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

; rdi   SDL_Renderer *
; rsi   Point
; rdx   block_size
; rcx   SDL_Color
draw_block:
        push    rbp
        mov     rbp, rsp 
        sub     rsp, SDL_Rect.size
        push    r12
        mov     r12, rdi
        push    rdx
        push    rsi

        mov     rax, rcx
        mov     r10, rax
        shr     rax, 16
        movzx   esi, ah
        movzx   edx, al   
        movzx   r8d, r10b
        shr     r10d, 8
        movzx   ecx, r10b
        call    SDL_SetRenderDrawColor

        pop     rsi
        mov     r10d, esi
        shr     rsi, 32
        mov     r11d, esi

        pop     rdx
        imul    r10d, edx
        imul    r11d, edx
        mov     dword [rsp + SDL_Rect.x], r10d
        mov     dword [rsp + SDL_Rect.y], r11d
        mov     dword [rsp + SDL_Rect.w], edx
        mov     dword [rsp + SDL_Rect.h], edx

        mov     rdi, r12
        lea     rsi, [rsp + SDL_Rect]
        call    SDL_RenderFillRect

        pop     r12
        leave
        ret

; rdi Board *
draw_snake:
        push    r15
        push    r14
        push    r13

        mov     r14, rdi
        mov     r13d, dword [r14 + Board.snake + Snake.length]
        xor     r15, r15
        .loop:
        cmp     r15d, r13d
        je      .end_loop

        mov     rdi, [r14 + Board.renderer]
        mov     rsi, [r14 + Board.snake + Snake.tail + (r15 * Point.size)]
        mov     edx, 20
        mov     ecx, 0xffff00ff
        call    draw_block

        add     r15d, 1
        jmp     .loop
        .end_loop:

        mov     rsi, qword [r14 + Board.snake + Snake.tail + (0 * Point.size)]
        mov     edx, dword [r14 + Board.snake + Snake.tail + Point.y]
        mov     rdi, print_snake_str
        call    printf

        pop     r13
        pop     r14
        pop     r15
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
        leave
        ret


        section .rodata
print_snake_str:
        db      "(%d, %d),", 0xa