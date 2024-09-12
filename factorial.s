.data
welcome: .asciz "\n-=-{ factorializer }-+-{ welcome }-=-\n\n"
prompt: .asciz "please enter factorial base (positive)\n"
result: .asciz "the result is: %ld\n"

base: .quad 0

input_type: .asciz "%ld"

.text
.global main

main:
    pushq %rbp              #prologue psuh the basepointer on top of stack
    movq %rsp, %rbp         # push stack pointer naar de basepointer

    movq $welcome, %rdi     # kopieer welcome string op rdi
    call printf             # print de welkom string

    movq $0, %rax           # free up space on rax
    subq $32, %rsp          # free up space op de stack
    movq $input_type, %rdi  # move inpute type string in rsi
    leaq -16(%rbp), %rsi    # adress the free space in rsi
    call scanf              # put input in -16(rsp)
    movq -16(%rbp), %rsi    # copy input in rsi

    call factorial          # call the start of the loop

    movq $result, %rdi      # move string result in rdi
    movq %rdx, %rsi         # move result in rsi
    call printf             # print result 

    movq %rbp, %rsp         # epilogue, move the base pointer to the stack pointer
    popq %rbp               # delete information on the stack

    movq $0, %rdi           # exit code
    call exit



factorial:

    movq $1, %rdx           # move 1 on rdx (output)
    cmpq $0, %rsi           # compare input with 0 
    jne factorial_loop      # if rdx is not zero jump to factorial loop else return rdx wich is 1


factorial_loop:
    
    imulq %rsi, %rdx        # calculate the multiplication of base and output
    subq $1, %rsi           # subtract 1 from input
    cmpq $0, %rsi           # compare base with zero
    jg factorial_loop       # jump if rcx is bigger than 0

loop_end:
    ret



