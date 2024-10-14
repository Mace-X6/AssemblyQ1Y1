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
    pushq   %rdi                    # save rdi
    call arg_counter
    popq    %rdi                    # restore rdi

    # rax contains the number of arguments



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

    jmp     epilogue_and_return

#   ARG_COUNTER
#   @params
#       rdi -   an adress pointing to the start of a zero terminated string
#
#   @return
#       rax -   an int (the amount of placeholders in the string)
#
arg_counter:        # run through the zero terminated string starting at the addr in rdi & return the number of placeholders in rax

    #   prologue
    pushq   %rbp
    movq    %rsp,   %rbp
    pushq   %r13                    # store callee saved registers
    pushq   %r13                    # store callee saved registers

    # r13 (or r13b) will hold the current byte being evaluated <current_char>
    # rax will be the output and the placeholder_counter
    # % = 37, d = 100, s = 115, u = 117
    movq    $0,     %r13
    movq    $0,     %rax
    counter_loop:
        movl    (%rdi),     %r13b

        # if current_char == NUL ? jump END
        cmp     %r13b,     $0
        je      end_loop

        # if current_char == % ? test next char
        cmp     %r13b,     $37
        je      test_byte_after_esc_char

        # else increment and loop
        addq    $1,     %rdi
        jmp     counter_loop

    test_byte_after_esc_char:
        addq    $1,         %rdi    # increment current_char_index   

        # if current_char == NUL ? jump END
        cmp     %r13b,     $0
        je      end_loop

        # if current_char == d ? placeholder_counter ++ 
        cmp     %r13b,     $100
        je      increment_placeholder_counter

        # if current_char == s ? placeholder_counter ++ 
        cmp     %r13b,     $115
        je      increment_placeholder_counter

        # if current_char == u ? placeholder_counter ++ 
        cmp     %r13b,     $117
        je      increment_placeholder_counter

        # else increment and loop
        addq    $1,     %rdi
        jmp     counter_loop

    increment_placeholder_counter:
        addq    $1,     %rax    # increment placeholder_counter
        addq    $1,     %rdi    # increment current_char_index  
        jmp     counter_loop
    
    end_loop:

    # return rax
    popq    %r13                # restore callee saved regs
    popq    %r13                # restore callee saved regs

    jmp epilogue_and_return

#   GET_ARGUMENT_N
#   @params
#       rdi -   number of argument to return
#
#   @return
#       rax -   argument n
#       rdi -   specifies if rax contains adress or direct value (1 | 0 respectively)
#
get_argument_n:
    #   prologue
    pushq   %rbp
    movq    %rsp,   %rbp

    # if argument_n == 0 ? jump return_RSI
    cmp     %rdi,     $0
    je      return_RSI

    # if argument_n == 1 ? jump return_RDX
    cmp     %rdi,     $1
    je      return_RDX

    # if argument_n == 2 ? jump return_RCX
    cmp     %rdi,     $2
    je      return_RCX

    # if argument_n == 3 ? jump return_R8
    cmp     %rdi,     $3
    je      return_R8

    # if argument_n == 4 ? jump return_R9
    cmp     %rdi,     $4
    je      return_R9

    # if argument_n == 4 ? jump return_R9
    jg

    # if fall-through ? jump epilogue_and_return
    jmp     epilogue_and_return

    return_RSI:
        # return RSI
        movq    $0,     %rdi
        movq    %rsi,   %rax
        jmp     epilogue_and_return

    return_RDX:
        # return RDX
        movq    $0,     %rdi
        movq    %rdx,   %rax
        jmp     epilogue_and_return

    return_RCX:
        # return RCX
        movq    $0,     %rdi
        movq    %rcx,   %rax
        jmp     epilogue_and_return

    return_R8:
        # return R8
        movq    $0,     %rdi
        movq    %r8,    %rax
        jmp     epilogue_and_return

    return_R9:
        # return R9
        movq    $0,     %rdi
        movq    %r9,    %rax
        jmp     epilogue_and_return

    
    





epilogue_and_return:
    #   epilogue
    movq    %rbp,   %rsp    # move SP back
    popq    %rbp            # restore BP
    ret                     # return
