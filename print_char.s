.text
#    char:   .byte   0x60      #96
.global main
main:
    pushq   %rbp
    movq    %rsp,   %rbp

    xorq    %rdi,   %rdi
    movb    $97,  %dil
    call    print_char

    movq    %rbp,   %rsp
    popq    %rbp
    movq    $60,    %rax            # exit call
    movq    $0,     %rdi            # exit call
    syscall    
                         # exit call
#   PRINT_CHAR
#   @params 
#       rdi - contains single char in dl
#
print_char:         # write a single char that is stored in the least significant byte of rdi
    
    #   prologue
    pushq   %rbp
    movq    %rsp,   %rbp

    pushq   %rbx                    # save rbx bcs callee saved
    pushq   %rbx

    xorq    %rbx,   %rbx            # zero out rcx
    movb    %dil,   %bl             # move character to rcx
    movq    $1,     %rax            # sycall codes
    movq    $1,     %rdi            # syscall codes

    pushq   %rbx                    # push rcx to stack
    movq    %rsp,   %rsi            # move the adress of the starting char into rdi
    movq    $1,     %rdx            # write one byte

    syscall

    popq    %rbx                    # restore callee saved reg
    popq    %rbx                    #

    movq    %rbp,   %rsp
    popq    %rbp

    ret