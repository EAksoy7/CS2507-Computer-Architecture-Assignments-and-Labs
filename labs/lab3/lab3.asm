# Converting and printing a decimal integer into binary with only integer print syscalls

.text
li $t0, 5 		# Value to be converted, henceforth x
li $t1, 0x80000000	# Bit mask with MSB as 1

loop:
	and $t2, $t0, $t1	# AND value with mask and store the result in $t2
	sll $t3, $t1, 1		# Reduce he degree of the mask by 1 and store this value in $t3, henceforth smask
	srl $t1, $t1, 1		# Shift mask 1 bit to the right
	beqz $t2, print0	# If the bit is 0, print 0
	
	li $v0, 1		# Load integer print sycall id
	li $a0, 1		# Load value 1 into argument register
	syscall			# Print
	beqz $t1, end		# If the mask is all zeros, the number has been printed, jump to the end
	j loop			# Iterate loop

print0: 
	li $v0, 1		# Load integer print syscall id
	li $a0, 0		# Load value 0 into argument register
	syscall			# Print value
	j loop			# Iterate loop

end:
	