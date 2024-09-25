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
    movq -16(%rbp), %rdi    # copy input in rsi

    call factorial          # call the start of the loop

    movq %rax, %rbx         # store output in rbx because printf is fucking with my shit

    movq $result, %rdi      # move string result in rdi
    movq %rax, %rsi         # move result in rsi
    call printf             # print result 

    movq %rbx, %rax         # restore output to rax 

    movq %rbp, %rsp         # epilogue, move the base pointer to the stack pointer
    popq %rbp               # delete information on the stack

    movq $0, %rdi           # exit code
    call exit

factorial:
    pushq %rbp               # prologue psuh the basepointer on top of stack
    movq %rsp, %rbp          # push stack pointer naar de basepointer

    pushq %rdi               # store n to stack
    subq $1, %rdi            # pass n - 1 to self

    cmpq $1, %rdi            # if n == 1 -> return
    jl return

    call factorial          # otherwise calculate n - 1

    popq %rcx               # do calculations
    imulq %rcx, %rax
    
return:
    movq %rbp, %rsp         # epilogue, move the base pointer to the stack pointer
    popq %rbp               # delete information on the stack

    ret 





