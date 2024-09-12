.data
welcome: .asciz "\n-=-{ factorializer }-+-{ welcome }-=-\n\n"
prompt: .asciz "please enter factorial base (positive)\n"
result: .asciz "the result is: %ld\n"

base: .quad 0

input_type: .asciz "%ld"

.text
.global main

main:   
    #prologue
    pushq %rbp
    movq %rsp, %rbp
    movq $0, %rax 
    
    # print welcome message 
    movq $welcome, %rdi
    call printf

    #prompt for base
    movq $prompt, %rdi
    call printf

    #take input for base and store into %r12
    movq $0, %rax 
    subq $16, %rsp              # free up space on the stack
    movq $input_type, %rdi
    leaq -16(%rsp), %rsi        # load adress of freed space into rsi
    call scanf                  # scanf writes to loaded adress & rsi
    movq %rsi, %r12             # move the value stored by scanf into r12
 
    call factorial

    # the output is now stored in %rax
    
    # print the output
    movq $result, %rdi
    movq %rax, %rsi
    movq $0, %rax
    call printf

    # epilogue
    movq %rbp, %rsp
    popq %rbp

    # je moet 0 in rdi zetten anders gaat hij weer lopen janken dat het geen goeie exit is
    movq $0, %rdi
    call exit

factorial:
    # %r12 -> base
    # %rax  -> output

    # multiplies output by base--, base times and stores it back in output
    
    movq $1, %rax            # move 1 to output

    cmpq $0, %r12           # check if base is 0
    jne factorial_loop      # if not zero -> calculate, otherwise just return 1 (which is already in r8)
    

    ret


factorial_loop:
    # %rax is output,
    # %r12 is base

    # for each loop do output = base * output
    imulq %r12, %rax 

    # subtract one from base
    subq $1, %r12

    # continue if counter(== base) > 0, else end loop
    cmpq $0, %r12
    jg factorial_loop

loop_end:
    ret 