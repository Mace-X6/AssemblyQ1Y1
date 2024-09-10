.text
welcome: .asciz "-{ powerator }{ welcome }-\n\n"
prompt1: .asciz "please enter base (positive)\n"
prompt2: .asciz "please enter exponent (positive)\n" 
result: .asciz "the result is: %d\n"

base: .asciz "%d"
exp: .asciz "%d"

input_type: .asciz "%d"

.global main

main:   
    #prologue
    pushq %rbp
    movq %rsp, %rbp
    movq $0, %rax 
    
    # print welcome message 
    leaq welcome(%rip), %rdi
    call printf
    #clear the stack
    movq %rbp, %rsp

    # call input method
    call input

    # %rdi -> base
    # %rsi -> exponent
    leaq base(%rip), %rdi
    leaq exp(%rip), %rsi

    call power

    # the output is now stored in %rax
    call output

    call end

input:
    #prompt for base
    leaq prompt1(%rip), %rdi
    call printf
    #clear the stack
    movq %rbp, %rsp

    #take input for base and store into base
    leaq base(%rip), %rdi
    leaq base(%rip), %rsi
    call scanf
    #clear the stack
    movq %rbp, %rsp

    #prompt for power
    leaq prompt2(%rip), %rdi
    call printf
    #clear the stack
    movq %rbp, %rsp

    #take input for power and store into exp
    leaq exp(%rip), %rdi
    leaq exp(%rip), %rsi
    call scanf
    #clear the stack
    movq %rbp, %rsp

    ret

output:
    movq result(%rip), %rdi
    movq %rax, %rsi
    call printf
    #clear the stack
    movq %rbp, %rsp
    ret

power: # multiplies %rdi by itself %rsi times and stores it back in %rdi
    movq %rdi, %rax
    subq $1, %rsi   # subtract one from the counter because well it just works out that way (trust me i checked)
    call power_loop
    ret

power_loop:
    # exponent -> %rsi
    # %rax is output,
    # %rdi is base

    # for each loop do output = output * base
    imulq %rdi, %rax 

    # subtract one from counter(which is exponent)
    subq $1, %rsi

    # continue if counter > 0, else end loop
    testq %rsi, %rsi
    jg power_loop

loop_end:
    ret

end:
    # epilogue
    movq %rbp, %rsp
    popq %rbp
    call exit