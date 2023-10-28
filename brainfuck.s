.global brainfuck

.bss
	arr: .space 240000
.text

format_str: .asciz "We should be executing the following code:\n%s"
char: .asciz "%c"

# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.
brainfuck:
	pushq %rbp
	movq %rsp, %rbp

	# save variables for other subroutines to not mess with them
	push %rbx
	push %r15
	push %r14
	push %r13
	push %r12
	push %r11

	# initialize variables
	mov %rdi, %rbx          # rbx = pointer to the format string

	xor %r13, %r13 # the char counter
	mov $arr, %r12 # the pointer

	loop:
		lea (%rbx, %r13), %r15 	# store the char pointer in %r15
		xor %r14, %r14 			# zero out %r14
		movb (%r15), %r14b 		# store the char in %r14b

		// increment the value at the data pointer
		plus:
			cmpb $'+', %r14b
			jne minus

			addb $1, (%r12)
			jmp loop_end
		
		// decrement the value at the data pointer
		minus:
			cmpb $'-', %r14b
			jne shift_right

			addb $-1, (%r12)
			jmp loop_end

		// shift data pointer one right
		shift_right:
			cmpb $'>', %r14b
			jne shift_left

			add $1, %r12
			jmp loop_end

		// shift data pointer one left
		shift_left:
			cmpb $'<', %r14b
			jne left_bracket

			add $-1, %r12
			jmp loop_end

		// compare if 0, if so jump over to corresponding right bracket
		// otherwise push current char counter
		left_bracket:
			cmpb $'[', %r14b
			jne right_bracket

			cmpb $0, (%r12)
			je parentheses_match

			push %r13
			push %r13
			jmp loop_end

		// pop the previously pushed char counter value and jump there
		right_bracket:
			cmpb $']', %r14b
			jne dot_print
			
			pop %r13
			pop %r13
			jmp loop

		// prints the value at the current data pointer as ASCII char
		dot_print:
			cmpb $'.', %r14b
			jne ask_input

			push %r14
			push %r14
			push %r13
			push %r12

			xor %rsi, %rsi
			mov (%r12), %sil
			// mov $1, %rdx
			// mov $1, %rax
			// mov $1, %rdi
			// syscall
			mov $char, %rdi
			call printf

			pop %r12
			pop %r13
			pop %r14
			pop %r14

			jmp loop_end
		
		// store one byte of input at current data pointer
		ask_input:
			cmpb $',', %r14b
			jne termination

			mov $char, %rdi
			xor %rsi, %rsi
			mov %r12, %rsi

			push %r12
			push %r11
			xor  %rax, %rax
			call scanf

			pop %r11
			pop %r12
			jmp loop_end

		termination:
			cmpb $0, %r14b
			je end

		// increment char counter and loop back
		loop_end:
			inc %r13
			jmp loop

	// pop callee saved registers
	end:
	popq  %r11
	popq  %r12
	popq  %r13
	popq  %r14
	popq  %r15
	popq  %rbx

	movq %rbp, %rsp
	popq %rbp
	ret

// Checks for position of matching right bracket
parentheses_match:
	// push registers that are reused
	push %r15
	push %r14
	xor %r14, %r14 #bracket counter

	parentheses_loop:
		lea (%rbx, %r13), %r15 # the char
			
			// Check for left bracket, if so increment by one
			next_0p:
				cmpb $'[', (%r15)
				jne next_1p
				inc %r14
				jmp next_2p

			// Check for right bracket, if so decrement by one
			next_1p:
				cmpb $']', (%r15)
				jne next_2p
				dec %r14
				jmp next_2p
			
			// Check if counter is zero, if so jump to parentheses end
			next_2p:		
				cmp $0, %r14
				je parentheses_end

			// Increment char counter by one and jump to loop start
			parentheses_loop_end:
			inc %r13
			jmp parentheses_loop

	// increment %r13, pop saved registers and jump to main loop
	parentheses_end:
		inc %r13
		pop %r14
		pop %r15
		jmp loop

