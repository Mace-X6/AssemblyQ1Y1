.data
welcome: .asciz "\n    ____  ____ _       ____________  ___  __________  ____ \n   / __ \\/ __ \\ |     / / ____/ __ \\/   |/_  __/ __ \\/ __ \\\n  / /_/ / / / / | /| / / __/ / /_/ / /| | / / / / / / /_/ /\n / ____/ /_/ /| |/ |/ / /___/ _, _/ ___ |/ / / /_/ / _, _/ \n/_/    \\____/ |__/|__/_____/_/ |_/_/  |_/_/  \\____/_/ |_|  \n\n\n             _                       \n _ _ _  ___ | | ___  ___ ._ _ _  ___ \n| | | |/ ._>| |/ | '/ . \\| ' ' |/ ._>\n|__/_/ \\___.|_|\\_|_.\\___/|_|_|_|\\___.\n\n\n"
prompt1: .asciz "please enter base (positive)\n"
prompt2: .asciz "please enter exponent (positive)\n" 
result: .asciz "the result is: %d\n"

base: .quad 0
exp: .quad 0

string_type: .asciz "%d"

.text
.global main

main:   
    #prologue
    pushq %rbp
    movq %rsp, %rbp
    movq $0, %rax 
    
    # print welcome message 
    leaq welcome(%rip), %rdi
    call printf

    # call input method
    call input

    # %r8 -> base
    # %r9 -> exponent
    movq base(%rip), %r8
    movq exp(%rip), %r9

    call power

    # the output is now stored in %rax
    call output

    call end

input:
    pushq %rbp #WHAAAATTTTT
    movq %rsp, %rbp

    #prompt for base
    leaq prompt1(%rip), %rdi
    call printf

    #take input for base and store into base
    movq $string_type, %rdi
    lea base(%rip), %rsi
    call scanf

    #prompt for exponent
    leaq prompt2(%rip), %rdi
    call printf

    #take input for power and store into exp
    movq $string_type, %rdi
    leaq exp(%rip), %rsi
    call scanf

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
    # %r8 -> base
    # %r9 -> exponent

    movq $1, %rax #put 1 into rax

    cmpq $0, %r9 # check if exponent is 0
    jne calculate # if not zero -> calculate, otherwise just return 1 (which is already in rax)

    ret

calculate:
    call power_loop
    ret

power_loop:
    # %rax is output,
    # %r8 is base
    # %r9 is exponent

    # for each loop do output = base * ouput
    imulq %r8, %rax 

    # subtract one from counter(which is exponent)
    subq $1, %r9

    # continue if counter > 0, else end loop
    testq %r9, %r9
    jg power_loop

loop_end:
    ret

end:
    # epilogue
    movq %rbp, %rsp
    popq %rbp

    # je moet 0 in rdi zetten anders gaat hij weer lopen janken dat het geen goeie exit is
    movq $0, %rdi
    call exit