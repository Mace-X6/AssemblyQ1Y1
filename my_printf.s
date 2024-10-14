.data
#   msg: 
#       .asciz "Hello World!"
#        len = . - msg

.text

.global main

main:
            # how is this gonna work:
            # first run through the string to look at the amount of 
            # arguments the function will need to take. the first 5 of these arguments are
            # in RSI, RDX, RCX, R8, R9, BP - 16 * (n + 1)
    #   prologue
    pushq   %rbp
    pushq   $8
    movq    %rsp,   %rbp

    pushq   %rbx                    # save all callee saved registers, regardless of if they're used
    pushq   %r12                    # save all callee saved registers, regardless of if they're used
    pushq   %r13                    # save all callee saved registers, regardless of if they're used
    pushq   %r14                    # save all callee saved registers, regardless of if they're used
    pushq   %r15                    # save all callee saved registers, regardless of if they're used
    pushq   %r15                    # save all callee saved registers, regardless of if they're used

    # RDI contains format string adress

    # RSI contains


#    movq   $1,  %rax               syscall call param for: write
#    movq   $1,  %rdi               syscall call param for: stdout
#    movq   $msg,    %rsi           syscall call param for: content to be written
#    movq   $len,    %rdx           syscall call param for: content length
#    syscall                        execute syscall

    popq    %r15                    # restore all callee saved registers
    popq    %r15                    # restore all callee saved registers
    popq    %r14                    # restore all callee saved registers
    popq    %r13                    # restore all callee saved registers
    popq    %r12                    # restore all callee saved registers
    popq    %rbx                    # restore all callee saved registers

    #   epilogue
    movq    %rbp,   %rsp
    popq    %rbp
    popq    %rbp

    movq    $60,    %rax            # exit call
    movq    $0,     %rdi            # exit call
    syscall                         # exit call

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

    xor     %rbx,   %rbx            # zero out rcx
    movq    %rdi,   %rbx            # move character to rcx
    movq    $1,     %rax            # sycall codes
    movq    $1,     %rdi            # syscall codes

    pushl   %bl                     # push a single byte to stack
    addq    $2,     %rsp            # move the SP back up to the beginning of the char
    movq    %rsp,   %rdi            # move the adress of the starting char into rdi
    movq    $1,     %rdx            # write one byte

    syscall

    popq    %rbx                    # restore callee saved reg
    popq    %rbx                    #

    #   epilogue
    movq    %rbp,   %rsp
    popq    %rbp

    ret                             # return

#   ARG_COUNTER
#   @params
#       rdi -   an adress pointing to the start of a zero terminated string
#
#   @return
#       rax -   an int (the amount of placeholders in the string)
#
arg_counter:        # run through the zero terminated string starting at the addr in rdi & return the number of placeholders in rax
    