.data
	inputStr: .space 3        # reserve 3 bytes in the memory to be used for taking user input
	askString: .asciiz "Enter a two-digit integer [00-99]: \n"   	# store a program messages (ask string) in the memory 
	intValue:  .word 0
	output: .asciiz "\nThe binary representation of your integer is:\n"   # store another program messages in the memory 
.text

main:
        ############### Lab 1 starts here ###############
	# ask the user for input
	la $a0, askString
	li $v0, 4
	syscall	

	# get the user string input (sycall 8) 
	li $v0, 8	
	li $a1, 3	
	la $a0, inputStr     	
	move $t0, $a0		# move from address to temporary register t0
	syscall		### inputStr Ready ###
	
	# Prepare inputStr for conversion procedure
	la $s1, ($t0)
	lbu $a0, 0($s1)	
	lbu $a1, 1($s1)
	jal str2int
	sw $v0, intValue	# store content of $t0 into 
	
	#############  Lab 1 ends here - input vallue in in $t7 and memory ############	
	#############  Lab 2 Printing Binary  ############
	li $v0, 4
	la $a0, output
	syscall		### intValue Ready ### 

	# convert int into the binary form
	lw $t0, intValue 	# load the value 
	add $t1, $zero, 0x80	# mask t1 to check for bit #7 (printing only 8 bits)
	add $t5, $zero, 8     # loop counter (printing only 8 bits)
	# loop: check every bit and print 0 or 1 after cgecking it using the mask register
	my_loop:
	and $t2, $t1, $t0
	beq $t2, 0, printZero
	# if not zero --> print 1
	add $a0, $zero, 1
	li $v0, 1
	syscall 
	j morebits	
	#print the output
	printZero:
	add $a0, $zero, 0
	li $v0, 1
	syscall 	
	morebits: 
	srl $t1, $t1, 1		# shift the 1 in mask to check the next bit 
	sub $t5, $t5, 1		# subtract 1 from $t5
	bne $t5, $zero, my_loop		# go back in the loop until $t5 is zero
	
	li $v0, 10			# load syscall exit into $v0.
	syscall				# make the syscall.
	

	str2int:
	# Converts 2 digit string number to integer
	sub $a0, $a0, 48	# conversion in ascii by subtracting 48 from tens
	sub $a1, $a1, 48	# conversion in ascii by subtracting 48 from units
	mul $a0, $a0, 10	# multiply the tenth digit by ten
	add $t0, $a0, $a1	# add back the two numbers into a new register
	move $v0, $t0		# store content of $t0 into $v0
	jr $ra
	
	printIntBinary:
	
	jr $ra

