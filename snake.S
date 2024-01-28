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
    # init SDL 
    mov edi, offset .str.print_no
    mov esi, dword ptr [SDL_INIT_VIDEO]
    call printf
    mov edi, SDL_INIT_VIDEO
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
    je error 

    # create renderer
    xor rdx, rdx
    mov rdi, r12
    mov rsi, -1
    mov rdx, 0
    call SDL_CreateRenderer
    mov r13, rax # store the renderer pointer
    cmp r13, 0x0
    je error 

    # set renderer color 
    mov rdi, r13 
    mov rsi, 0
    mov rdx, 0xff
    mov rcx, 0
    mov r8, 0xff
    call SDL_SetRenderDrawColor

    mov rdi, r13
    call SDL_RenderClear
    mov rdi, r13
    call SDL_RenderPresent

    # delay for 5 seconds
    mov rdi, 5000
    call SDL_Delay

    mov rdi, r12
    call SDL_DestroyWindow
    call SDL_Quit
    jmp main_function_end

error:
    call SDL_GetError
    mov rsi, rax
    mov edi, offset .str.error
    call printf

main_function_end:
    xor rax, rax
    leave
    ret


    # Read Only Data
    .section    .rodata
SDL_INIT_VIDEO:
    .long 0x000020u
SDL_WINDOWPOS_CENTERED:
    .long 0x2FFF0000u
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

