.text

print_format: .asciz "%c"

.include "helloWorld.s"

.global main

# ************************************************************
# Subroutine: decode                                         *
# Description: decodes message as defined in Assignment 3    *
#   - 2 byte unknown                                         *
#   - 4 byte index                                           *
#   - 1 byte amount                                          *
#   - 1 byte character                                       *
# Parameters:                                                *
#   first: the address of the message to read       (%rdi)   *
#   return: no return value                                  *
# ************************************************************

decode:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	#rdi contains the message
	pushq %rdi				# store %rdi on stack
	pushq %rdi				# twice for alignment
	movq %rdi, %rcx			# store the content at address %rdi in %rcx
loop:
	movq (%rcx), %rcx		# store the content at address %rcx in %rcx

	movq $0, %r8			# clear r8
	movb %cl, %r8b 			# r8 contains current char

	shr $8, %rcx			# shift rcx towards lsb so %cl is set on repetitions

	movq $0, %r9			# clear all of r9
	movb %cl, %r9b			# r9 contains current repetitions

	push %rcx				# save rcx because printf is gonna fuck with it 
	push %rcx				# push twice for alignment
print_loop:
	
	
	subq $1, %r9			# subtract from loop condition
	pushq %r9				# save r9
	pushq %r8				# save r8

	movq $print_format, %rdi# pass format to printf
	movq %r8, %rsi 			# pass char to be printed
	movq $0, %rax 			# buh buh buh
	call printf				# print the char

	popq %r8				# retrieve r8
	popq %r9				# retrieve r9

	cmp $1, %r9				# compare r9 to 1

	# if
	jge print_loop			# if greater or equal to 1, do loop again, otherwise just continue

	# else
	# next up: deal with address
	popq %rcx				# restore rcx because the scanf monster has left
	popq %rcx				# twice for alignment
	shr $8, %rcx			# ecx now contains next index
	movq $0, %rsi			# clear rsi
	movl %ecx, %esi			# put next index in rsi

	# if
	cmp $0, %esi			# if next address offset is 0, return
	je return

	popq %rdi				# restore %rdi
	popq %rcx				# also copy rdi to rcx (so rcx contains the base addr)

	pushq %rdi				# save again
	pushq %rdi				# alignment

	imulq $8, %rsi			# next address is index * 8
	addq %rsi, %rcx			# rcx contains the base addr, rsi contains the offset towards next offset
	jmp loop				# rcx contains the addr of next code.

return:
	# epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

main:
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq	$MESSAGE, %rdi	# first parameter: address of the message
	call	decode			# call decode

	popq	%rbp			# restore base pointer location 
	movq	$0, %rdi		# load program exit code
	call	exit			# exit the program

