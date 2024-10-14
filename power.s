.data
welcome: .asciz "\n    ____  ____ _       ____________  ___  __________  ____ \n   / __ \\/ __ \\ |     / / ____/ __ \\/   |/_  __/ __ \\/ __ \\\n  / /_/ / / / / | /| / / __/ / /_/ / /| | / / / / / / /_/ /\n / ____/ /_/ /| |/ |/ / /___/ _, _/ ___ |/ / / /_/ / _, _/ \n/_/    \\____/ |__/|__/_____/_/ |_/_/  |_/_/  \\____/_/ |_|  \n\n\n             _                       \n _ _ _  ___ | | ___  ___ ._ _ _  ___ \n| | | |/ ._>| |/ | '/ . \\| ' ' |/ ._>\n|__/_/ \\___.|_|\\_|_.\\___/|_|_|_|\\___.\n\n\n"
prompt1: .asciz "please enter base (positive)\n"
prompt2: .asciz "please enter exponent (positive)\n" 
result: .asciz "the result is: %ld\n"

input_type: .asciz "%ld"

.text
.global main

main:   
    #prologue
    pushq %rbp
    movq %rsp, %rbp
    movq $0, %rax 

    pushq %r12
    pushq %r13
    
    # print welcome message 
    movq $welcome, %rdi
    call printf

    #prompt for base
    movq $prompt1, %rdi
    call printf

    #take input for base and store into %r12
    movq $0, %rax 
    subq $16, %rsp              # free up space on the stack
    movq $input_type, %rdi
    leaq -16(%rbp), %rsi        # load adress of freed space into rsi
    call scanf                  # scanf writes to loaded adress & rsi
    movq -16(%rbp), %r12        # move the value stored by scanf into r12

    #prompt for exponent
    movq $prompt2, %rdi
    call printf

    #take input for power and store into %r13
    movq $0, %rax 
    subq $16, %rsp              # free up space on the stack
    movq $input_type, %rdi
    leaq -16(%rbp), %rsi        # load adress of freed space into rsi
    call scanf                  # scanf writes to loaded adress & rsi
    movq -16(%rbp), %r13        # move the value stored by scanf into r13

    movq %r12, %rdi
    movq %r13, %rsi
 
    call pow

    # the output is now stored in %rax
    
    # print the output
    movq $result, %rdi
    movq %rax, %rsi
    movq $0, %rax
    call printf

    popq %r13
    popq %r12

    # epilogue
    movq %rbp, %rsp
    popq %rbp

    # je moet 0 in rdi zetten anders gaat hij weer lopen janken dat het geen goeie exit is
    movq $0, %rdi
    call exit

pow:
    #prologue
    pushq %rbp
    movq %rsp, %rbp
    
    # %rdi -> base
    # %rsi -> exponent

    # multiplies output by base, exponent times and stores it back in output

    movq $1, %rax               # put 1 into rax

    cmpq $0, %rsi               # check if exponent is 0
    jne power_loop              # if not zero -> calculate, otherwise just return 1 (which is already in rax)
    
    # epilogue
    movq %rbp, %rsp
    popq %rbp
    ret


power_loop:
    # %rax -> output,
    # %rdi -> base
    # %rsi -> exponent

    # continue if counter > 0, else end loop
    cmpq $0, %rsi

    # for each loop do output = base * ouput
    imulq %rdi, %rax 

    # subtract one from counter(which is exponent)
    subq $1, %rsi

    jg power_loop # checks the compare on line 99 

loop_end:
    
    # epilogue
    movq %rbp, %rsp
    popq %rbp

    ret 