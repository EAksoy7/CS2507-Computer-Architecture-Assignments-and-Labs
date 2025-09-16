.data
	prompt1: .asciiz "Enter the first integer:"
	mess1: .asciiz "The entered integer + 5 = \n"
	const1: .word 5
.text
	la $a0, prompt1 	# Load address of prompt1 into $a0 
	li $v0, 4 		# Load print syscal id into $v0 
	syscall 		# Print message to screen 
	li $v0, 5		# Load read user input syscall id into $v0
	syscall			# Read user input
	move $t0, $v0		# Move this input to $t0
	add  $t0, $t0, $t0	# Add $t0 to itsel
	lw $t1, const1		# Load integer constant into $t1
	add $t0, $t0, $t1	# Add integer constant to $t0
	 
	li $v0, 4		# Load print syscall id into $v0
	la $a0, mess1		# Load address of prompt2 into $a0
	syscall			# Print message to screen
	move $a0, $t0		# Load sum to $a0
	li $v0, 1
	syscall			# Print sum to screen