.data
	prompt1: .asciiz "Please enter 2 integers: "
	prompt2: .asciiz "\nThe value you entered, in integer form, is: "
	i_buffer: .word
.text
	# Reading user input
	la $a0, prompt1 	# Load address of prompt into $a0
	li $v0, 4		# Load print syscall
	syscall 		# Print prompt
	li $v0, 8		# Load the read string syscall into $v0
	la $a0, i_buffer	# Load address of i_buffer into $a0
	li $a1, 3		# Read 2 characters when reading user input
	syscall			# Read user input
	lb $t1, 0($a0)		# Load first character int $t1
	lb $t2, 1($a0)		# Load second character int $t2
	
	# Converting input from string to int
	subi $t1, $t1, 0x30	# Subtract 0x30 from both characters, getting their integer vaue
	subi $t2, $t2, 0x30
	li $t3, 10		# Move immediate value 10 to $t3, this will be used to multiply our first digit to get tens
	mult $t1, $t3		# Multiply first value by 10 to get tens
	mflo, $t1		# Move this value to $t1
	add $t1, $t1, $t2	# Put the final value into $t1

	# Printing converted int
	li $v0, 4		# Load print string syscall id
	la $a0, prompt2		# Load address of second prompt
	syscall			# Print second prompt
	li $v0, 1		# Load print integer syscall id
	move $a0, $t1		# Move calculated integer to input register
	syscall			# Print converted integer