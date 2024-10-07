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

	movq 	$1, %rsi		# make sure rsi contains 1
	
	call decoder

	# epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret
decoder:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	#rdi contains the message
	pushq %rdi				# store %rdi on stack
	pushq %rdi				# twice for alignment

	# if
	cmp $1, %rsi 
	je base_case			# if rsi contains 1 -> this is the basecase so jump to basecase

	# if
	cmp $0, %rsi 
	je stop_case			# if rsi contains 0 -> this is the final case so jump to end

	# else
	addq %rsi, %rdi			# add the previously determined offset, or if it is the first iteration, add 0

base_case:
	movq (%rdi), %rcx		# store the content at address %rdi in %rcx

	movq $0, %r8			# clear r8
	movb %cl, %r8b 			# r8 contains current char

	shr $8, %rcx			# shift rcx towards lsb so %cl is set on repetitions

	movq $0, %r9
	movb %cl, %r9b			# r9 contains current repetitions

print_loop:
	subq $1, %r9			# subtract from loop condition

	pushq	%r9				# save stuff
	pushq	%r8				# more saving
	pushq	%rcx
	pushq	%rsi
	

	movq $print_format, %rdi# pass format to printf
	movq %r8, %rsi 			# pass char to be printed
	movq $0, %rax 			# buh buh buh
	call printf				# print the char

	popq %rsi
	popq %rcx
	popq %r8				# revert everything
	popq %r9				#

	cmp $1, %r9

	# if
	jge print_loop			# if greater or equal to 1, do loop again, otherwise just continue

	# else
	# next up: deal with address

	shr $8, %rcx			# ecx now contains next index
	movq $0, %rsi			# clear rsi
	movl %ecx, %esi			# put next index in rsi

	imulq $8, %rsi			# next address is index * 8
	popq %rdi				# restore %rdi
	popq %rdi				# 

	# epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 

	#rdi now contains base address
	#rsi contains the offset to next address

	call decoder

stop_case:
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

