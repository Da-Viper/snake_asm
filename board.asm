%include "snake.inc"
        section .text
global  create_food
global  draw_food
global  draw_block
global  draw_snake
global  init_snake
global  has_collision
global  print_snake
global  set_direction
global  update_score_texture
global  update_food
global  update_snake


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

        sub     eax, 1
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


; rdi: Board *
has_collision:
        ; collides with wall
        ; if head.x
        ; comp head.x to 0 
        mov     esi, dword [rdi + Board.snake + Snake.head.x]
        cmp     esi, 0 ; less than zero
        jl      .true

        mov     edx, dword [rdi + Board.width]
        cmp     esi, edx ; greater than the board width
        jge      .true

        mov     esi, dword [rdi + Board.snake + Snake.head.y]
        cmp     esi, 0 ; height less than zero
        jl      .true

        mov     edx, dword [rdi + Board.height]
        cmp     esi, edx ; greater than the board height
        jge      .true
        
        xor     eax, eax
        ret
        
        .true:
        mov     eax, 1
        ret


; function to create the food from random numbers
; rdi: Board *
create_food:
	; compute rand from width and height then store it 
	; mov the board * 
        push    r12
        push    r13
        mov     r12, rdi

        call    rand
        xor     edx, edx
        mov     ecx, dword [ r12 + Board.width]
        div     ecx
        mov     dword [ r12 + Board.food.x], edx
        mov     r13d, edx

        call    rand
        xor     edx, edx
        mov     ecx, dword [ r12 + Board.height]
        div     ecx
        mov     dword [ r12 + Board.food.y], edx

        pop     r13
        pop     r12
        ret

; rdi Board *
update_score_texture:
        push    rbp
        push    r12
        sub     rsp, 8
        ; mov     rbp, rsp

        mov     r12, rdi
        ; format the string
        lea     rdi, qword [r12 + Board.score_buffer]
        mov     esi, 16
        mov     rdx, score_text 
        mov     ecx, dword [r12 + Board.score]
        call    SDL_snprintf

        ; create the text surface
        mov     rdi, qword [r12 + Board.font]
        lea     rsi, qword [r12 + Board.score_buffer]
        ; mov     rsi, score_text
        mov     edx, 0xffffffff
        call    TTF_RenderText_Blended

        mov     rdi, qword [r12 + Board.renderer]
        mov     rsi, rax
        call    SDL_CreateTextureFromSurface
        mov     qword [r12 + Board.score_texture], rax

        add     rsp, 8
        pop     r12
        pop     rbp
        ret        

; rdi Board *
update_food:
        push    rbp
        mov     rbp, rsp
        push    r12
        ; check if food colides with the snake head
        ; if yes update food location and increment score
        mov     rsi, qword [rdi + Board.snake + Snake.head]
        mov     rdx, qword [rdi + Board.food]
        xor     rax, rax
        cmp     rsi, rdx
        jne     .end

        add     dword [rdi + Board.score], 1
        add     dword [rdi + Board.snake + Snake.length], 1

        mov     r12, rdi
        call    update_score_texture
        mov     rdi, r12
        call    create_food


        .end:
        pop     r12
        leave
        ret

; rdi Board *
update_snake:
        mov     rsi, qword [rdi + Board.direction]
        mov     edx, dword [rdi + Board.snake + Snake.length] ; size
        sub     edx, 1

        .loop:
        cmp     edx, 0
        jl      .loop_end

        mov     rcx, qword [rdi + Board.snake + Snake.head + (rdx * Point.size) ] ; save the current
        mov     qword [rdi + Board.snake + Snake.head + ((rdx + 1)  * Point.size) ], rcx ; move to next

        sub     edx, 1
        jmp     .loop
        .loop_end:

        add     dword [rdi + Board.snake + Snake.head.x], esi
        shr     rsi, 32
        add     dword [rdi + Board.snake + Snake.head.y], esi

        ret

; rdi   SDL_Renderer *
; rsi   Point
; rdx   block_size
; rcx   SDL_Color
draw_block:
        push    rbp
        mov     rbp, rsp 
        push    r12
        push    rdx
        push    rsi

        mov     r12, rdi
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

        sub     rsp, SDL_Rect.size
        mov     dword [rsp + SDL_Rect.x], r10d
        mov     dword [rsp + SDL_Rect.y], r11d
        mov     dword [rsp + SDL_Rect.w], edx
        mov     dword [rsp + SDL_Rect.h], edx

        mov     rdi, r12
        lea     rsi, [rsp + SDL_Rect]
        call    SDL_RenderFillRect

        add     rsp, SDL_Rect.size
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


        ; draw tail
        .loop:
        cmp     r15d, r13d
        je      .end_loop

        mov     rdi, [r14 + Board.renderer]
        mov     rsi, [r14 + Board.snake + Snake.tail + (r15 * Point.size)]
        mov     edx, 20
        mov     ecx, 0x008080ff
        call    draw_block

        add     r15d, 1
        jmp     .loop
        .end_loop:

        mov     rsi, qword [r14 + Board.snake + Snake.tail + (0 * Point.size)]
        mov     edx, dword [r14 + Board.snake + Snake.tail + Point.y]
        mov     rdi, print_snake_str
        call    printf

        ; draw snake head 
        mov     rdi, [r14 + Board.renderer]
        mov     rsi, [r14 + Board.snake + Snake.head]
        mov     edx, 20
        mov     ecx, 0xffff00ff
        call    draw_block

        pop     r13
        pop     r14
        pop     r15
        ret

; rdi Board *
; rsi byte [ 0,1, 2, 3] up, down, left, right
set_direction:
        cmp     esi, 4
        jg      .end
        cmp     esi, 1
        jl      .end

        sub     esi, 1
        mov     edx, dword [snake_direction + (rsi * Point.size) + Point.x]
        mov     ecx, dword [snake_direction + (rsi * Point.size) + Point.y]
        mov     [rdi + Board.direction.x], edx
        mov     [rdi + Board.direction.y], ecx

        .end:
        ret



; function to draw the food
; rdi: Board * 
draw_food:
        mov     rsi, [rdi + Board.food]
        mov     rdi, qword [rdi + Board.renderer]
        mov     edx, BLOCK_SIZE
        mov     ecx, BLUE
        jmp     draw_block


        section .rodata
score_text: 
        dd      "Score: %d"
print_snake_str:
        db      "(%d, %d),", 0xa

snake_direction:  ; x , y 
        dd      0
        dd      -1
        dd      0
        dd      1
        dd      -1
        dd      0
        dd      1
        dd      0
