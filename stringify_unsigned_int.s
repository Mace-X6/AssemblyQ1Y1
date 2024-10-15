.text
#    char:   .byte   0x60      #96
.global main
main:
    #   prologue
    pushq   %rbp
    movq    %rsp,   %rbp

    #save r15
    pushq   %r15
    pushq   %r15

    # save sp
    movq    %rsp,   %r15
    
    # pass args
    movq    $11538942706234, %rdi
    movq    %rsp,   %rsi

    #reserve space for response
    subq    $24,    %rsp

    call    stringify_unsigned_int

    xorq    %r8,    %r8 # will hold amount of chars written
    # r15 is the starting pos
    loop:
    xorq    %rdi,   %rdi    # clr rdi
    movb    (%r15), %dil    # arguments for print call

    pushq   %rax            # save rax because my print char fucks with it
    pushq   %rax

    call    print_char

    popq    %rax            # reinstate rax
    popq    %rax

    inc     %r15            # next char
    inc     %r8

    cmp     %r8,    %rax
    # if r8 == rax exit loop
    # else
    jg      loop

    addq    $24,    %rsp
    popq    %r15
    popq    %r15

    # epilogue and exit
    movq    %rbp,   %rsp
    popq    %rbp
    movq    $60,    %rax            # exit call
    movq    $0,     %rdi            # exit call
    syscall                         # exit call



#> SUBROUTINES <##################################################################
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
    cmp     $0,     %rdi    
    jne      BCD_loop

    pushq   $0
    inc     %r12                # if only one zero will be printed, r12 should still be one to account for the loop
    jmp     post_loop

    BCD_loop:
        xorq    %rcx,   %rcx    #clr rcx
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
