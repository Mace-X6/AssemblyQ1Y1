.data
#   msg: 
#       .asciz "Hello World!"
#        len = . - msg

.text

.global my_printf

my_printf:
            # how is this gonna work:
            # first run through the string to look at the amount of 
            # arguments the function will need to take. the first 5 of these arguments are
            # in RSI, RDX, RCX, R8, R9, BP + 16 * (n + 1)
    #   prologue
    pushq   %rbp
    movq    %rsp,   %rbp

    pushq   %r9                     # bp -8
    pushq   %r8                     # bp -16
    pushq   %rcx                    # bp -24
    pushq   %rdx                    # bp -32
    pushq   %rsi                    # bp -40
    pushq   %rdi                    # bp -48

    pushq   %rbx                    # save all callee saved registers, regardless of if they're used
    pushq   %r12                    # save all callee saved registers, regardless of if they're used
    pushq   %r13                    # save all callee saved registers, regardless of if they're used
    pushq   %r14                    # save all callee saved registers, regardless of if they're used
    pushq   %r15                    # save all callee saved registers, regardless of if they're used
    pushq   %r15                    # save all callee saved registers, regardless of if they're used

    # RDI contains format string adress
    # % = 37, d = 100, s = 115, u = 117
    movq    $0,     %r13            # will hold currentchar
    movq    $0,     %r14            # will hold the number of arguments used
    print_loop:
        movl    (%rdi),     %r13b   # move next char to r13

        # if current_char == NUL ? jump END
        cmp     %r13b,     $0
        je      end_loop

        # if current_char == % ? test next char
        cmp     %r13b,     $37
        je      test_next_char

        # else print increment and loop
        pushq   %rdi                # save rdi 
        pushq   %rdi                # twice to keep stack aligned
        movq    $0,     %rdi        # clear rdi
        movl    %r13b,  %dl         # move char to rdi
        popq    %rdi                # restore rdi
        popq    %rdi                # restore rdi

        addq    $16,     %rdi
        jmp     print_loop

    test_next_char:     # if this is jumped to, the prev char was %
        addq    $16,         %rdi    # increment current_char_index   

        # if current_char == NUL ? jump END
        cmp     %r13b,     $0
        je      end_loop

        # if current_char == d ? handle it : jump to not_d
        cmp     %r13b,     $100
        jne      not_d
            pushq   %rdi            # save rdi
            pushq   %rax

            movq    %r14,   %rdi    # passing arg number to subroutine
            
            call get_argument_n
            # rax contains address of string

            addq    $1,     %r14    # next placeholder wild hold next arg.
            movq    $0,     %rdi    # clear rdi
            d_loop:
                movl    (%rax),     %dl
                # if current_char == NUL ? jump END
                cmp     %dl,    $0
                je      d_loop_end

                # else print char increment and loop
                call    print_char
                addq    $1,     %rax
                jmp     d_loop

            d_loop_end:
            popq    %rax
            popq    %rdi


        not_d:

        # if current_char == s ? handle it : jump to not_s
        cmp     %r13b,     $115
        jne      not_s
        not_s:
    

        # if current_char == u ? handle it : jump to not_u
        cmp     %r13b,     $117
        jne      not_u
        not_u:

        # if current_char == % ? handle it : jump to not_percent
        cmp     %r13b,     $37
        jne      not_percent
            # handling it:
            pushq   %rdi                # save rdi 
            pushq   %rdi                # twice to keep stack aligned
            movq    $0,     %rdi        # clear rdi
            movl    %r13b,  %dl         # move char to rdi
            call    print_char          # print the char in dl
            popq    %rdi                # restore rdi
            popq    %rdi                # restore rdi
            
            addq    $16,     %rdi        # increment current_char_index
            jmp     print_loop          # loop
        not_percent:

        # else print whatever format specifier and loop
        pushq   %rdi                # save rdi 
        pushq   %rdi                # twice to keep stack aligned
        movq    $0,     %rdi        # clear rdi

        movl    $37,  %dl           # move % to rdi
        call    print_char          # print the char in dl

        movl    %r13b,  %dl         # move char to rdi
        call    print_char          # print the char in dl

        popq    %rdi                # restore rdi
        popq    %rdi                # restore rdi
        addq    $16,     %rdi       # increment current char
        jmp     print_loop
    
    end_loop:

    


    popq    %r15                    # restore all callee saved registers
    popq    %r15                    # restore all callee saved registers
    popq    %r14                    # restore all callee saved registers
    popq    %r13                    # restore all callee saved registers
    popq    %r12                    # restore all callee saved registers
    popq    %rbx                    # restore all callee saved registers

    #   epilogue
    movq    %rbp,   %rsp
    popq    %rbp

    movq    $60,    %rax            # exit call
    movq    $0,     %rdi            # exit call
    syscall                         # exit call

#>  SUBROUTINES <####################################################################################################
#
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


#
#   ARG_COUNTER (not used)
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
        movl    (%rdi),     %r13b   # move next char to r13

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
        addq    $16,        %rdi    # increment current_char_index   

        # if current_char == NUL ? jump END
        cmp     %r13b,     $0
        je      end_counter_loop

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
        addq    $16,     %rdi
        jmp     counter_loop

    increment_placeholder_counter:
        addq    $1,     %rax    # increment placeholder_counter
        addq    $16,     %rdi    # increment current_char_index  
        jmp     counter_loop
    
    end_counter_loop:

    # return rax
    popq    %r13                # restore callee saved regs
    popq    %r13                # restore callee saved regs

    jmp epilogue_and_return

#
#   GET_ARGUMENT_N
#   @params
#       rdi -   number of argument to return
#
#   @return
#       rax -   argument n (either a value or an address)
#
get_argument_n:     # return the nth argument of my_printf (if n > the number of given arguments it will return a random value)
    #   prologue
    pushq   %rbp
    movq    %rbp,   %r8 # remember bp for later
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

    # if argument_n > 4 ? jump return_R9
    jg      return_STACK_item

    # if fall-through ? jump epilogue_and_return
    jmp     epilogue_and_return

    return_RSI:
        # return RSI
        movq    -40(%r8),   %rax
        jmp     epilogue_and_return

    return_RDX:
        # return RDX
        movq    -32(%r8),   %rax
        jmp     epilogue_and_return

    return_RCX:
        # return RCX
        movq    -24(%r8),   %rax
        jmp     epilogue_and_return

    return_R8:
        # return R8
        movq    -16(%r8),    %rax
        jmp     epilogue_and_return

    return_R9:
        # return R9
        movq    -8(%r8),    %rax
        jmp     epilogue_and_return

    return_STACK_item:
        # return a stack address
        addq    $16,    %r8     # step past return addr and saved bp
        subq    $3,     %rdi    # rdi is now equal to which item needs to be taken from the stack (1 indexed)
        imulq   $16,    %rdi    # calculate the offset this equates to
        movq    (%r8,   %rdi),  %rax    # move the item to rax

        jmp     epilogue_and_return
    
# as a shorthand to jump to
epilogue_and_return:
    #   epilogue
    movq    %rbp,   %rsp    # move SP back
    popq    %rbp            # restore BP
    ret                     # return
