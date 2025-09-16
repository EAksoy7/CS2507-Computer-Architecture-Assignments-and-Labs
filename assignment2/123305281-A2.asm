.data
    	inputStr: .space 8    
    	str2float: .word
    	exponentHex: .byte
    	fractionHex: .space 3
    	message1: .asciiz "Emin Aksoy (123305281) is implementing the core assignment\n"
    	prompt1: .asciiz "Please enter a real number in the form xxx.yyy: "
    	signMessage: .asciiz "\nThe sign bit of your number is: "
    	message3: .asciiz "\nThe exponent of your number is: "
    	message4: .asciiz "\nThe fraction of your number is: "
    	result: .space 8

.text
    	la $a0, message1    	# Load message into argument register
    	li $v0, 4        	# Load string printing syscall into $v0
    	syscall            	# Print the message
    	la $a0 prompt1        	# Load prompt1 into argument register
    	syscall            	# Print prompt

    	li $v0, 8        	# Load user string input sycall into $v0
    	la $a0, inputStr    	# Load address of reserved input space for input buffer
    	move $t0, $a0        	# Store address of input buffer in $t0
    	li $a1, 8        	# Set max character input to 8 characters
    	syscall            	# Read user input


	# LEFT SIDE OF DECIMAL POINT
	# Firt handles the 2nd and 3rd characters, since they are both digits, while the first character could be a digit or a - sign
	lbu $t3 2($t0)        	# Load third digit into $t2
  	sub $t3, $t3, 48    	# Convert to int from ascii
  	
  	lbu $t2, 1($t0)        	# Load second digit into $t1
  	sub $t2, $t2, 48    	# Convert to int from ascii
   	mul $t2, $t2, 10    	# Multiply digit by appropriate power
   	
   	add $t4, $t2, $t3
	
	# Now handling the first character
    	lbu $t1, 0($t0)        	# Load first digit into $t0
    	sub $t9, $t1, 45	# The - symbol is ASCII 45, so subtracting 45 would make $t9 0
    	beqz $t9, Negative
    	
    	sub $t1, $t1, 48    	# Convert to int from ascii
	mul $t1, $t1, 100    	# Multiply digit by appropriate power
	add $t4, $t4, $t1
	li $t9, 1		# $t9 is the sign, if the number is positive it is 1, if it is negative, $t9 is -1
	
	j RightSideDecimal
  	
Negative:    
	li $t9, -1
	mul $t4, $t4, $t9

RightSideDecimal:
    	# RIGHT SIDE OF DECIMAL POINT
    	lbu $t1, 4($t0)        	# Load first digit into $t0
    	sub $t1, $t1, 48    	# Convert to int from ascii
	mul $t1, $t1, 100    	# Multiply digit by appropriate power

  	lbu $t2 5($t0)        	# Load second digit into $t1
  	sub $t2, $t2, 48    	# Convert to int from ascii
   	mul $t2, $t2, 10    	# Multiply digit by appropriate power

  	lbu $t3 6($t0)        	# Load third digit into $t2
  	sub $t3, $t3, 48    	# Convert to int from ascii
	
	add $t5, $t1, $t2	# Add tens to hundreds
  	add $t5, $t5, $t3	# Add units to hundreds and tens
  	


FloatConversion:
	li $t6, 1000	# Move divisor to $t6
	
	mtc1 $t4, $f0		# Move exponent to $f0
	mtc1 $t5, $f2		# Move mantissa to $f2
	mtc1 $t6, $f4		# Move divisor to $f4
	mtc1 $t9, $f6		# Move sign to $f6
	
	cvt.s.w $f0, $f0	# Convert exponent from int to float
	cvt.s.w $f6, $f6
	
	div.s $f2, $f2, $f4	# Divide mantissa by divider
	mul.s $f2, $f2, $f6	# Multiply mantissa by sign
	add.s $f8, $f0, $f2	# Add exponent and mantissa
	
	
	s.s $f8, str2float	# Store float value in memory
	
	# SPLITTING FLOAT
	lw $t0, str2float	# Load float value into $t0
	
	li $t2, 0x7f800000
	
	and $t1, $t0, $t2	# Find exponent
	srl, $t1, $t1, 23
	move $s1, $t1
	
	li $t2, 0x007fffff
	
	and $t1, $t0, $t2
	move $s0, $t1
	
	
	
    	
    	
    	
    	
    	# PRINTING SIGN BIT
    	la $a0, signMessage	# Load address of second message
    	li $v0, 4		# Load string printing syscall
    	syscall			# Print message
    	addi $t8, $t9, 1 
    	
    	beqz $t8, negSign
    	
    	li $a0, 0
    	li $v0, 1
    	syscall
    	j endNegSign
    	
    	negSign:
    	li $a0, 1
    	li $v0, 1
    	syscall
    	
    	endNegSign:
    
    	# PRINTING EXPONENT
	la $a0, message3
	li $v0, 4
	syscall
	move $a0, $s1
	jal printHex

	
	
	# PRINTING FRACTION
	la $a0, message4
	syscall
	li $t1, 0x00ff0000
	and $a0, $s0, $t1
	srl $a0, $a0, 4
	jal printHex
	
	li $t1, 0x0000ff00
	and $a0, $s0, $t1
	srl $a0, $a0, 2
	jal printHex
	
	li $t1, 0x000000ff
	and $a0, $s0, $t1
	jal printHex
	
	
	
	li $v0, 10		# Load program exit syscall
    	syscall		# Exit program

	
	
printHex:

	li $t0, 2
	la $t1, result
	ror $a0, $a0, 8
Loop:
	beqz $t0, Exit
	rol $a0, $a0, 4
	and $t2, $a0, 0xf
	ble $t2, 9, Sum
	addi $t2, $t2, 87
	
	b Iterate
	
Sum:
	addi $t2, $t2, 48

Iterate: 
	sb $t2, 0($t1)
	addi $t1, $t1, 1
	addi $t0, $t0, -1
	
	j Loop 

    	
 
Exit:	
	la $a0, result
	li $v0, 4
	syscall    	
	jr $ra

    	