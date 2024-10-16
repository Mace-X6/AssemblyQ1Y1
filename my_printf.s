.data
string: .asciz "My name is %s. I think I'll get a %d for my exam. What does %r do? And %%?\n"
arg1:   .asciz "Piet"
.bss 
    stored_string: .skip 1024
.text

.global main
main:
#prolog
    pushq   %rbp
    movq    %rsp,   %rbp

    movq    $string,  %rdi
    movq    $arg1,    %rsi
    movq    $-42,     %rdx

    call my_printf

#epilog
    movq    %rbp,   %rsp
    popq    %rbp

#exit
    movq    $60,    %rax            # exit call
    movq    $0,     %rdi            # exit call
    syscall                         # exit call

my_printf:
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
    xorq    %r13,     %r13            # will hold currentchar
    xorq    %r14,     %r14            # will hold the number of arguments used
    xorq    %rbx,     %rbx            # will hold the string length
    print_loop:
        movb    (%rdi),     %r13b     # move next char to r13

        # if current_char == NUL ? jump END
        cmp     $0,       %r13
        je      end_loop

        # if current_char == % ? test next char
        cmp     $37,      %r13
        je      test_next_char

        # else print increment and loop
        pushq   %rdi                # save rdi 
        pushq   %rsi                # rsi
        pushq   %rdx
        pushq   %rdx

        xorq    %rdi,   %rdi        # clear rdi
        xorq    %rsi,   %rsi        # clear rsi

        movq    %rbx,   %rdx         # pass current str length
        movb    %r13b,  %dil         # move char to rdi
        movq    $stored_string, %rsi # pass starting addr.

        call save_char

        movq    %rax,   %rbx         # store new string length

        popq    %rdx
        popq    %rdx
        popq    %rsi                # restore rsi
        popq    %rdi                # restore rdi

        inc     %rdi                # increment char
        jmp     print_loop

    test_next_char:     # if this is jumped to, the prev char was %
        inc     %rdi    # increment current_char_index
        movb    (%rdi),     %r13b     # move next char to r13


        # if current_char == NUL ? jump END
        cmp     $0,       %r13b     
        je      end_loop

        # if current_char == d ? handle it : jump to not_d
        cmp     $100,     %r13b
        jne      not_d
            pushq   %rax
            pushq   %rcx 
            pushq   %rdx 
            pushq   %rdi 
            pushq   %rsi 
            pushq   %r8
            pushq   %r9
            pushq   %r10
            pushq   %r11
            # i have no fucking clue which of this im using in the rest of my loop because i forgot how 
            # i wrote it and this bullshit is unreadable so im pushing everyhting its allright

            #save r15
            pushq   %r15

            # save sp
            movq    %rsp,   %r15

            movq    %r14,   %rdi    # passing arg number to subroutine
            
            call get_argument_n

            inc     %r14            # next placeholder will use next arg
            # rax contains address of string

            # pass args
            movq    %rax, %rdi
            movq    %rsp,   %rsi

            #reserve space for response
            subq    $32,    %rsp

            call    stringify_signed_int

            xorq    %r8,    %r8 # will hold amount of chars written
            # r15 is the starting pos
            loop1:

            pushq   %rax            # save rax because my print char fucks with it

            pushq   %rdi                # save rdi 
            pushq   %rsi                # rsi
            pushq   %rdx

            movb    (%r15), %dil    # arguments for print call
            xorq    %rdi,   %rdi        # clear rdi
            xorq    %rsi,   %rsi        # clear rsi

            movq    %rbx,   %rdx         # pass current str length
            movq    $stored_string, %rsi # pass starting addr.

            call    save_char

            movq    %rax,   %rbx         # store new string length

            popq    %rdx
            popq    %rsi                # restore rsi
            popq    %rdi                # restore rdi

            popq    %rax            # reinstate rax

            inc     %r15            # next char
            inc     %r8

            cmp     %r8,    %rax
            # if r8 == rax exit loop
            # else
            jg      loop1

            addq    $32,    %rsp
            popq    %r15            # restore everything

            # okay since i pushed all that junk i restore everything here (i hope i dont run out of stack)
            popq   %r11
            popq   %r10
            popq   %r9
            popq   %r8
            popq   %rsi 
            popq   %rdi 
            popq   %rdx 
            popq   %rcx 
            popq   %rax
            
            inc     %rdi                # increment current_char_index
            jmp     print_loop          # loop

        not_d:

        # if current_char == s ? handle it : jump to not_s
        cmp      $115,     %r13     
        jne      not_s
            
            pushq   %rdi            # save rdi
            pushq   %rax

            movq    %r14,   %rdi    # passing arg number to subroutine
            
            call get_argument_n
            # rax contains address of string

            inc     %r14            # next placeholder wild hold next arg.
            xorq    %rdi,   %rdi    # clear rdi
            d_loop:
                movb    (%rax),     %dil
                # if current_char == NUL ? jump END
                cmp     $0,     %dil
                je      d_loop_end

                # else print char increment and loop
                pushq   %rax        #save rax       
                pushq   %rax        #save rax   
                
                
                movq    %rbx,   %rdx         # pass current str length
                movq    $stored_string, %rsi # pass starting addr.
                call    save_char
                movq    %rax,   %rbx         # store new len

                popq    %rax        #restore rax
                popq    %rax        #restore rax
                
                addq    $1,     %rax
                jmp     d_loop

            d_loop_end:
            popq    %rax            # restore values 
            popq    %rdi            # restore values
            inc     %rdi            # increment char
            jmp     print_loop      # loop
        
            
        not_s:
    

        # if current_char == u ? handle it : jump to not_u
        cmp      $117,      %r13     
        jne      not_u

            pushq   %rax
            pushq   %rcx 
            pushq   %rdx 
            pushq   %rdi 
            pushq   %rsi 
            pushq   %r8
            pushq   %r9
            pushq   %r10
            pushq   %r11
            # i have no fucking clue which of this im using in the rest of my loop because i forgot how 
            # i wrote it and this bullshit is unreadable so im pushing everyhting its allright

            #save r15
            pushq   %r15

            # save sp
            movq    %rsp,   %r15

            movq    %r14,   %rdi    # passing arg number to subroutine
            
            call get_argument_n
            
            inc     %r14            # next placeholder will use next arg
            # rax contains address of string

            # pass args
            movq    %rax,   %rdi
            movq    %rsp,   %rsi

            #reserve space for response
            subq    $32,    %rsp

            call    stringify_unsigned_int

            xorq    %r8,    %r8 # will hold amount of chars written
            # r15 is the starting pos
            loop:
            xorq    %rdi,   %rdi    # clr rdi
            movb    (%r15), %dil    # arguments for print call

            pushq   %rax            # save rax because my print char fucks with it
            pushq   %rax

            
            movq    %rbx,   %rdx         # pass current str length
            movq    $stored_string, %rsi # pass starting addr.
            call    save_char
            movq    %rax,   %rbx         # store new len

            popq    %rax            # reinstate rax
            popq    %rax

            inc     %r15            # next char
            inc     %r8

            cmp     %r8,    %rax
            # if r8 == rax exit loop
            # else
            jg      loop

            addq    $32,    %rsp
            popq    %r15            # restore everything

            # okay since i pushed all that junk i restore everything here (i hope i dont run out of stack)
            popq   %r11
            popq   %r10
            popq   %r9
            popq   %r8
            popq   %rsi 
            popq   %rdi 
            popq   %rdx 
            popq   %rcx 
            popq   %rax
            
            inc     %rdi                # increment current_char_index
            jmp     print_loop          # loop

        not_u:

        # if current_char == % ? handle it : jump to not_percent
        cmp     $37,        %r13      
        jne      not_percent
            # handling it:
            pushq   %rdi                # save rdi 
            pushq   %rdi                # twice to keep stack aligned

            xorq    %rdi,   %rdi       # clear rdi
            movb    %r13b,  %dil        # move char to rdi

            movq    %rbx,   %rdx         # pass current str length
            movq    $stored_string, %rsi # pass starting addr.

            call    save_char          # print the char in dil

            movq    %rax,   %rbx       # store new len

            popq    %rdi                # restore rdi
            popq    %rdi                # restore rdi
            
            inc     %rdi                # increment current_char_index
            jmp     print_loop          # loop
        not_percent:

        # else print whatever format specifier and loop
        pushq   %rdi                # save rdi 
        pushq   %rdi                # twice to keep stack aligned
        xorq    %rdi,   %rdi        # clear rdi

        movb    $37,  %dil           # move % to rdi
        movq    %rbx,   %rdx         # pass current str length
        movq    $stored_string, %rsi # pass starting addr.
        call    save_char          # print the char in dil
        movq    %rax,   %rbx       # store new len

        movb    %r13b,  %dil         # move char to rdi
        movq    %rbx,   %rdx         # pass current str length
        movq    $stored_string, %rsi # pass starting addr.
        call    save_char          # print the char in dil
        movq    %rax,   %rbx       # store new len

        popq    %rdi                # restore rdi
        popq    %rdi                # restore rdi
        inc     %rdi               # increment current char
        jmp     print_loop
    
    end_loop:

    movq    $1,              %rax   #syscall write
    movq    $1,              %rdi   # syscall sdout write
    movq    $stored_string,  %rsi   # addr of first char to write
    movq    %rbx,            %rdx   # length of string

    syscall

    popq    %r15                    # restore all callee saved registers
    popq    %r15                    # restore all callee saved registers
    popq    %r14                    # restore all callee saved registers
    popq    %r13                    # restore all callee saved registers
    popq    %r12                    # restore all callee saved registers
    popq    %rbx                    # restore all callee saved registers

    #   epilogue
    movq    %rbp,   %rsp
    popq    %rbp

    ret # returns all of my_printf



#>  SUBROUTINES <####################################################################################################
#
#   save_char
#   @params 
#       rdi - contains single char in dil
#       rsi - the start addr of the string
#       rdx - current size of the string
#
#   @return
#       rax -   size of the string
#
save_char:         # write a single char that is stored in the least significant byte of rdi
    
    #   prologue
    pushq   %rbp
    movq    %rsp,   %rbp

    addq    %rdx,   %rsi
    inc     %rsi

    movb    %dil,   (%rsi)

    movq    %rdx,   %rax
    inc     %rax

    #   epilogue
    movq    %rbp,   %rsp    # move SP back
    popq    %rbp            # restore BP
    ret                     # return


#
#   STRINGIFY_UNSIGNED_INT
#   @params
#       rdi -   an unsigned integer
#       rsi -   the starting address of a memory address on stack 24 bytes can be written to
#
#   @return
#       rax -   amount of bytes in the string
#
stringify_unsigned_int:
    # prologue
    pushq   %rbp
    movq    %rsp,   %rbp

    pushq   %r12            # save r12 (callee saved)
    pushq   %r13            # save r13 (callee saved)
    pushq   %r14            # save r14 (callee saved)
    pushq   %r14            # save r14 (callee saved)
    
    xorq    %r12,   %r12    # clear r12

    # if number == 0 ? push 0, skip loop : do loop
    cmp      $0,     %rdi    
    jne      BCD_loop

    pushq   $0
    inc     %r12                # if only one zero will be printed, r12 should still be one to account for the loop
    jmp     post_loop

    BCD_loop:
        xorq    %rcx,   %rcx    #clr rcx
        xorq    %rax,   %rax    #clr rax

        movq    $10,    %rcx    # set rcx equal to ten
        inc     %r12            # increment the length of the number
        #rdi contains number
        movq    %rdi,   %rax    # rax will contain result
        # rdx will contain remainder
        xorq    %rdx,   %rdx    #clear rdx so div can use it 
        div     %rcx            # div rdi by ten

        movq    %rax,   %rdi    # move the rest of the decimal number back to rdi
        pushq   %rdx            # remember the decimal we just figured out

        # if number is accounted for ? turn it into string : reloop
        cmp     $0,     %rdi
        jne     BCD_loop
    post_loop:
    #   r12 contains the length

    xorq    %r13,   %r13    # clear r13
    xorq    %r8,    %r8      # clear r8, it will remember every 8th time a char is added because a push is then required
    xorq    %r14,   %r14    # clear r14 (this will temporarily store the chars between pushes)
    movq    %r12,   %rax    # move the length of the string to the output
    
    get_char_loop:

        shl     $8,     %r14    # make space for next char (on first iteration this does nothing but thats ok)

        popq    %r13            # r13 now contains a decimal digit
        # ascii 0 = 48, so adding 48 to r13 will yield the ascii code of digits 0 thru 9
        addq    $48,    %r13    # r13 now contains the ascii code

        movb    %r13b,  %r14b   # mov char to r14
        inc     %r8             # add 1 to r8

        cmp     $8,     %r8
        # if r8 == 8 ? push r14, clr r8 : continue
        jne     after_push_buffer
        # else mov r14 to spec addr,    clr r8

        # i need to reorder the bytes so the endianess is reversed
        # %r10 holds the new reordered reg
        # %r11 the counter
        xorq    %r10,   %r10        #clr r10
        xorq    %r11,   %r11        #clr r11
        endianess_loop1:
            movb    %r14b,  %r10b       # move the last bit of r14 to the first bit of r11

            inc     %r11                # increment r11
            cmp     $8,     %r11
            jge     end_endianess_loop1     
            shr     $8,     %r14        # shift
            shl     $8,     %r10        # shift
            jmp     endianess_loop1

        end_endianess_loop1:
        movq    %r10,   %r14

        movq    %r14,   (%rsi)  # write chars to %rsi
        addq    $8,     %rsi    # subtract 8 from rsi so next push buffer will write to next 8 bytes
        xorq    %r8,    %r8     # set r8 back to zero

        after_push_buffer:

        dec     %r12

        cmp     $0,     %r12
        # if i > 0 ? loop
        jg      get_char_loop
        # else step out of loop

        #push remaining stuff
        cmp     $0,     %r8
        # if r8 is 0 -> dont do the next part
        je      after_last_push
        # else correctly shift the remaining bits and push 

        movq    $8,     %r9
        subq    %r8,    %r9
        # r9 contains the shift index
        mini_loop:              # so shift r14 left r9 times until 
            dec     %r9
            shl     $8,     %r14
            cmp     $0,     %r9
            jne     mini_loop

        # i need to reorder the bytes so the endianess is reversed
        # %r10 holds the new reordered reg
        # %r11 the counter
        xorq    %r10,   %r10        #clr r10
        xorq    %r11,   %r11        #clr r11
        endianess_loop:
            movb    %r14b,  %r10b       # move the last byte of r14 to the first bit of r10

            inc     %r11                # increment r11
            cmp     $8,     %r11
            jge     end_endianess_loop     
            shr     $8,     %r14        # shift
            shl     $8,     %r10        # shift
            jmp     endianess_loop

        end_endianess_loop:
        movq    %r10,   %r14

        movq    %r14,   (%rsi)
        after_last_push:
    
    popq   %r14            #restore r14 (callee saved)    
    popq   %r14            #restore r14 (callee saved)
    popq   %r13            #restore r13 (callee saved)
    popq   %r12            #restore r12 (callee saved)

    # rax contains string length in bytes
    movq    %rbp,   %rsp
    popq    %rbp

    ret        
        

#
#   STRINGIFY_SIGNED_INT
#   @params
#       rdi -   a signed integer
#       rsi -   the starting address of a memory address on stack 24 bytes can be written to
#
#   @return
#       rax -   amount of bytes in the string
#
stringify_signed_int:
    #   prologue
    pushq   %rbp
    movq    %rsp,   %rbp
    
    pushq   %rdi                    # save rdi 
    pushq   %rdi                    # save rdi

    shr     $63,    %rdi            # move msb to lsb
    xorq    %rax,   %rax            # clear rax
    movb    %dil,   %al             # move sign bit to cl

    popq    %rdi                    # restore rdi
    popq    %rdi                    # restore rdi

    cmp     $1,     %al             # check if sign bit is one

    # if sign == 0 ? jump positive : jump negative
    jne     stringify_positive      # if sign zero -> int is positive

    # else continue to negative
    stringify_negative:
        #   this is just the twos compliment math
        dec     %rdi                            # subtract 1 from rdi
        xorq    $0xFFFFFFFFFFFFFFFF,    %rdi    #xor with a string of ones will yield a flipped register

        # now put the negative sign on the reserved stack space and add one to the 
        movb    $0x2D,  (%rsi)
        addq    $1,     %rsi

        call stringify_unsigned_int

        addq    $1,     %rax        # rax contains the length of the string because of S_U_I but we need to add one because of the - char
        
        jmp     stringify_signed_epilogue

    stringify_positive:
        #   rdi now contains the unsigned positive counterpart
        #   rsi still contains starting addr

        call    stringify_unsigned_int

        # rax contains the length of the string written to the stack because thats what sui returns

        jmp     stringify_signed_epilogue

    stringify_signed_epilogue:
    movq    %rbp,   %rsp    # move SP back
    popq    %rbp            # restore BP
    ret                     # return
    
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
        movq    (%rdi),     %r13   # move next char to r13

        # if current_char == NUL ? jump END
        cmp     $0,     %r13b     
        je      end_loop

        # if current_char == % ? test next char
        cmp     $37,    %r13b     
        je      test_byte_after_esc_char

        # else increment and loop
        addq    $1,     %rdi
        jmp     counter_loop

    test_byte_after_esc_char:
        addq    $16,        %rdi    # increment current_char_index   

        # if current_char == NUL ? jump END
        cmp     $0,         %r13b
        je      end_counter_loop

        # if current_char == d ? placeholder_counter ++ 
        cmp     $100,       %r13b     
        je      increment_placeholder_counter

        # if current_char == s ? placeholder_counter ++ 
        cmp     $115,       %r13b     
        je      increment_placeholder_counter

        # if current_char == u ? placeholder_counter ++ 
        cmp     $117,       %r13b     
        je      increment_placeholder_counter

        # else increment and loop
        inc      %rdi
        jmp     counter_loop

    increment_placeholder_counter:
        addq    $1,     %rax    # increment placeholder_counter
        inc      %rdi    # increment current_char_index  
        jmp     counter_loop
    
    end_counter_loop:

    # return rax
    popq    %r13                # restore callee saved regs
    popq    %r13                # restore callee saved regs

        #   epilogue
    movq    %rbp,   %rsp    # move SP back
    popq    %rbp            # restore BP
    ret                     # return

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
    cmp     $0,     %rdi     
    je      return_RSI

    # if argument_n == 1 ? jump return_RDX
    cmp     $1,     %rdi     
    je      return_RDX

    # if argument_n == 2 ? jump return_RCX
    cmp     $2,     %rdi     
    je      return_RCX

    # if argument_n == 3 ? jump return_R8
    cmp     $3,     %rdi     
    je      return_R8

    # if argument_n == 4 ? jump return_R9
    cmp     $4,     %rdi     
    je      return_R9

    # if argument_n > 4 ? jump return_STACK_item
    jg      return_STACK_item

    # if fall-through ? epilogue and return
        #   epilogue
    movq    %rbp,   %rsp    # move SP back
    popq    %rbp            # restore BP
    ret                     # return

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
