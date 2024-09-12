.data
welcome: .asciz "\n    ____  ____ _       ____________  ___  __________  ____ \n   / __ \\/ __ \\ |     / / ____/ __ \\/   |/_  __/ __ \\/ __ \\\n  / /_/ / / / / | /| / / __/ / /_/ / /| | / / / / / / /_/ /\n / ____/ /_/ /| |/ |/ / /___/ _, _/ ___ |/ / / /_/ / _, _/ \n/_/    \\____/ |__/|__/_____/_/ |_/_/  |_/_/  \\____/_/ |_|  \n\n\n             _                       \n _ _ _  ___ | | ___  ___ ._ _ _  ___ \n| | | |/ ._>| |/ | '/ . \\| ' ' |/ ._>\n|__/_/ \\___.|_|\\_|_.\\___/|_|_|_|\\___.\n\n\n"
prompt1: .asciz "please enter base (positive)\n"
prompt2: .asciz "please enter exponent (positive)\n" 
result: .asciz "the result is: %ld\n"

base: .quad 0
exp: .quad 0

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
    movq $prompt1, %rdi
    call printf

    #take input for base and store into %r12
    movq $0, %rax 
    subq $16, %rsp              # free up space on the stack
    movq $input_type, %rdi
    leaq -16(%rsp), %rsi        # load adress of freed space into rsi
    call scanf                  # scanf writes to loaded adress & rsi
    movq %rsi, %r12             # move the value stored by scanf into r12

    #prompt for exponent
    movq $prompt2, %rdi
    call printf

    #take input for power and store into %r13
    movq $0, %rax 
    subq $16, %rsp              # free up space on the stack
    movq $input_type, %rdi
    leaq -16(%rsp), %rsi        # load adress of freed space into rsi
    call scanf                  # scanf writes to loaded adress & rsi
    movq %rsi, %r13             # move the value stored by scanf into r13

    call power

    # the output is now stored in %rax
    call output

    call end

input:
    pushq %rbp #WHAAAATTTTT
    movq %rsp, %rbp

    #prompt for base
    movq $prompt1, %rdi
    call printf

    #take input for base and store into %r12
    subq $16, %rsp              # free up space on the stack
    movq $input_type, %rdi
    leaq -16(%rsp), %rsi        # load adress of freed space into rsi
    call scanf                  # scanf writes to loaded adress
    popq %r12

    #prompt for exponent
    movq $prompt2, %rdi
    call printf

    #take input for power and store into %r13
    subq $16, %rsp              # free up space on the stack
    movq $input_type, %rdi
    leaq -16(%rsp), %rsi        # load adress of freed space into rsi
    call scanf                  # scanf writes to loaded adress
    popq %r13

    #clear the stack
    movq %rbp, %rsp
    popq %rbp
    ret

output:
    pushq %rbp #WHAAAATTTTT
    movq %rsp, %rbp

    movq $result, %rdi
    movq %rax, %rsi
    call printf

    #clear the stack
    movq %rbp, %rsp
    popq %rbp

    ret

power: 
    # multiplies output by base exponent times and stores it back in output
    # %r12 -> base
    # %r13 -> exponent

    movq $1, %rax #put 1 into rax

    cmpq $0, %r13 # check if exponent is 0
    jne power_loop # if not zero -> calculate, otherwise just return 1 (which is already in rax)
    
    ret

power_loop:
    # %rax is output,
    # %r12 is base
    # %r13 is exponent

    # continue if counter > 0, else end loop
    cmpq $0, %r13

    # for each loop do output = base * ouput
    imulq %r12, %rax 

    # subtract one from counter(which is exponent)
    subq $1, %r13

    jg power_loop # reference to compare on line 99 

loop_end:
    ret

end:
    # epilogue
    movq %rbp, %rsp
    popq %rbp

    # je moet 0 in rdi zetten anders gaat hij weer lopen janken dat het geen goeie exit is
    movq $0, %rdi
    call exit