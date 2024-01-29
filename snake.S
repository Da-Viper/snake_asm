    .intel_syntax noprefix

    .text
    # SDL functions
    .extern SDL_Init
    .extern SDL_CreateWindow
    .extern SDL_CreateRenderer
    .extern SDL_SetRenderDrawColor
    .extern SDL_RenderClear
    .extern SDL_RenderPresent
    .extern SDL_GetError
    .extern SDL_PollEvent
    .extern SDL_DestroyWindow
    .extern SDL_Quit

    .global main
    .type main, @function
main: 
    push rbp
    mov rbp, rsp
    xor rax, rax
    sub rsp, 64 # create stack space for SDL_Event(56)
    # init SDL 
    mov edi, dword ptr [SDL_INIT_VIDEO]
    call SDL_Init

    # create window
    mov edi, offset window_title
    mov esi, dword ptr [SDL_WINDOWPOS_CENTERED]
    mov edx, dword ptr [SDL_WINDOWPOS_CENTERED]
    mov ecx, dword ptr [window_width]
    mov r8d, dword ptr [window_height]
    mov r9d, 0
    call SDL_CreateWindow
    mov r12, rax # store the window pointer
    cmp r12, 0x0 # check if it is nullptr
    je handle_error 

    # create renderer
    xor rdx, rdx
    mov rdi, r12
    mov rsi, -1
    mov rdx, 0
    call SDL_CreateRenderer
    mov r13, rax # store the renderer pointer
    cmp r13, 0x0
    je handle_error 

    # set renderer color 
    mov rdi, r13 
    mov rsi, 0
    xor rdx, rdx
    mov rcx, 0xff
    mov r8, 0xff
    call SDL_SetRenderDrawColor

    mov rdi, r13
    call SDL_RenderClear
    mov rdi, r13
    call SDL_RenderPresent

    # delay for 5 seconds
    # mov rdi, 5000
    # call SDL_Delay

    mov r14, 1 # while true
    # initalize SDL event struct
    mov qword ptr [rsp + 8], 0
    mov qword ptr [rsp + 16], 0
    mov qword ptr [rsp + 24], 0
    mov qword ptr [rsp + 32], 0
    mov qword ptr [rsp + 40], 0
    mov qword ptr [rsp + 48], 0
    mov qword ptr [rsp + 56], 0
game_loop:
    lea rdi, [rsp + 8]
    call SDL_PollEvent # poll events
    
    cmp eax, 0
    jz game_loop

    mov edi, dword ptr [rsp + 8]
    cmp edi, dword ptr [SDL_QUIT]
    je game_loop_end

    cmp r14, 1
    je game_loop
game_loop_end:


sdl_cleanup:
    mov rdi, r12
    call SDL_DestroyWindow
    call SDL_Quit
    jmp main_function_end

handle_error:
    call SDL_GetError
    mov rsi, rax
    mov edi, offset .str.error
    call printf

main_function_end:
    xor rax, rax
    add rsp, 64
    leave
    ret


    # Read Only Data
    .section    .rodata
SDL_INIT_VIDEO:
    .long 0x000020u
SDL_WINDOWPOS_CENTERED:
    .long 0x2FFF0000u
SDL_QUIT:
    .long 0x100
.str.test:
    .asciz "Hello there i know %ld\n"
window_width:
    .long 800
window_height:
    .long 600
window_title:
    .asciz "This is the assembly code"
.str.helloWorld: 
    .asciz "Hello world\n"
.str.error:
    .asciz "Could not create SDL window: %s\n"
.str.print_no:
    .asciz "Print no: %d\n"
    # SDL_Const stuff

