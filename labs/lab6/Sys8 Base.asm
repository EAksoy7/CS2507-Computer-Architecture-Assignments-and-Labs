.data 
myString: .space 40

.text 
main:
		li $s0,0  # s0 represents the number of processed characters 
repeat: 	
		la $a0, myString     	#sys8 argument 1
		li $a1 30		#sys8 argument 2
		jal mysys8		# call sys8 procedure
		
		la $a0, myString	# use syscall 4 to print the received string 
		li $v0, 4
		syscall 		
		#  The program is finished. Exit.
 		li $v0, 10          # system call for exit
 		syscall               # Exit!
 # TODO   ==============================================
 		# using IO interfacing (keyboard and display simulator) 
 		# parse user string into the memory address provided in $a0 
 		# and up to the number of characters provided in $a1 
 		
 		# Note that syscall 8 
 		# For specified length n, string can be no longer than n-1. 
 		# If less than that, adds newline to end. 
 		# In either case, then pads with null byte.
 		
 		#  you would need to use parts of "lab 3 - simple IO.asm"
 		# note that sys8 may implement IO operation in a single
 		# procedure. Alternatively, it can be done by calling other
 		# procedures. 
 # =====================================================
  mysys8:
  		# your implementation goes here
	la	$t9, ($a0)		# Get address of myString
	move 	$t8, $a1

	lui 	$t0, 0xffff      	# t0 = address of Keyboard control register  0xffff 0000
	li 	$t1, 1            	# ready bit MASK (least significant bit) 0x0000 0001
key_wait:
	lbu 	$t2, ($t0)      	# Read keyboard control register  at  xffff 0000
	and	$t2, $t2, $t1 		# Apply ready bit  mask 
	beqz 	$t2, key_wait  		# 0 no key press --> busy waiting , 1 a key is pressed	
	lbu 	$t3, 4($t0)      	# load RECEIVER_DATA to $a0 
	sb	$t3, ($t9)
	addi	$t9, $t9, 1
	subi	$t8, $t8, 1
	beqz	$t8, finish
	j	key_wait

finish:
 	jr $ra
