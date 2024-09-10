    .data
input_type: .asciz "%d"
output_type: .asciz "ballen %d"
result: .space 128     # Allocate space for the input string

    .text
    .global main
main:
    # Prologue
    pushq %rbp
    movq %rsp, %rbp

    movq $input_type, %rdi    
    lea result(%rip), %rsi    
    call scanf

    movq result(%rip), %rax

    movq $output_type, %rdi   
    movq %rax, %rsi    
    call printf

    # Epilogue
    movq %rbp, %rsp
    popq %rbp
    call exit
