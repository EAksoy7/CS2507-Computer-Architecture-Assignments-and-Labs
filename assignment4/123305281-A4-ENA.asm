	.data
fivehundred_message: .asciiz "The processor is doing useful work until it is interrupted - itteration: "

###############################################################################
# Learn about exceptions and interrupts handling in Mips. 
# First version by Karl Marklund <karl.marklund@it.uu.se>
###############################################################################
###############################################################################
# USER TEXT SEGMENT
# MARS start to execute at label main in the user .text segment.
###############################################################################
	.globl main
	.text
main:
	#######################################################
	# >>>>>>>>>>>>>>> ASSIGNMENT PART 2 <<<<<<<<<<<<<<<<#
	#######################################################
        #ASSIGNMENT TODO 2:  Enable simulator keyboard interrupts. 	
	# Hint: Get the value of the keyboard ""control"" register and 
	# set the interrupt enable bit WITHOUT changing other bits
 	lw $t1, 0xffff0000
	or $t1, 2
	sw $t1, 0xffff0000
 

infinite_loop: 		
	#######################################################
	# >>>>>>>>>>>>>>> ASSIGNMENT PART 1 <<<<<<<<<<<<<<<<#
	#######################################################
	# ASSIGNMENT TODO 1: 
	# This infinite loop simulates the CPU doing something useful
	# write down the code that would print 
	# a line of your choice every 500 iterations
	addi $s0, $s0, 1

	div $t0 $s0, 500
	mfhi $t0
	beq $t0, $zero, print_500_iteration

	j main
	
print_500_iteration:
	li $v0, 4			# Print string syscall id
	la $a0, fivehundred_message	# Load message to be printed every 500 iterations
	syscall				# Print the message
	
	li $v0, 1	# Print integer syscall id
	move $a0, $s0	# move current iteration to arg register
	syscall		# Print current iteration
	
	li $v0, 11	# Print character sycall id
	li $a0, 10 	# Ascii '\n'
	syscall		# Print newline	
	
	j main

###############################################################################
# KERNEL DATA SEGMENT
###############################################################################
		.kdata
UNHANDLED_EXCEPTION:	.asciiz "===>      Unhandled exception       <===\n\n"
UNHANDLED_INTERRUPT: 	.asciiz "===>      Unhandled interrupt       <===\n\n"
OVERFLOW_EXCEPTION: 	.asciiz "===>      Arithmetic overflow       <===\n\n" 
TRAP_EXCEPTION: 		.asciiz "===>         Trap exception         <===\n\n"
BAD_ADRS_EXCEPTION: 	.asciiz "===>   Bad data address exception   <===\n\n"
INTERRUPT_MESSAGE: 	.asciiz "Interrupt "
INTERRUPT_FIRED: 	.asciiz " is fired\n"
INTERRUPT_INACTIVE:	.asciiz " is inactive\n"
# Variables for save/restore of registers used in the handler
	save_v0:    .word   0
	save_a0:    .word   0
	save_at:    .word   0
	save_t0:    .word   0
	save_t1:    .word   0

###############################################################################
# KERNEL TEXT SEGMENT 
###############################################################################
# The kernel handles all exceptions and interrupts.
# 
# The registers $k0 and $k1 should never be used by user level programs and 
# can be used exclusively by the kernel. 
#
# In a real system the kernel must make sure not to alter any registers
# in usr by any of the user level programs. For all such registers, the kernel
# must make sure to save the register valued to memory before use. Later, before 
# resuming execution of a user level program the kernel must restore the 
# register values from memory. 
# 
# Note, that if the kernel uses any pseudo instruction that translates 
# to instructions using $at, this may interfere with  user level programs 
# using $at. In a real system, the kernel must  also save and restore the 
# value of $at. 
###############################################################################

   		# The exception vector address for MIPS32.
   		.ktext 0x80000180  # store this code starting at this address in kernel  part				
   		# Save ALL registers modified in this handler, except $k0 and $k1
		#  we can save registers to static variables.
		sw      $v0, save_v0   #save $v0
		sw      $a0, save_a0  #save $a0
		sw	$t0, save_t0  #save $t0
		sw	$t1, save_t1  #save $t1
		.set    noat     # do not use $at from here 
		sw      $at, save_at  #save $at
		.set    at       # $at can now be used  
		# starting processing the exception
		mfc0 $k0, $13   		# Get value in CAUSE register
		andi $k1, $k0, 0x00007c  	# Mask all but the exception code (bits 2 - 6) to zero.
		srl  $k1, $k1, 2	  		# Shift two bits to the right to get the exception code in $k1
		beqz $k1, __interrupt	# if exception code is zero --> it is  an interrupt
__exception:			# exceptions are processed here 
	# Practice TODO:replace OVERFLOW_CAUSE_VALUE by the corresponding number 
	beq $k1,  12, __overflow_exception 	

	# Practice TODO: Add needed code below to branch to label __bad_address_exception. 	
	beq $k1, 4, __bad_address_exception
	beq $k1, 5, __bad_address_exception
	# Practice TODO: Add code to branch to label __trap_exception 
	beq, $k1, 13, __trap_exception
	
__unhandled_exception: 
		# It's not really proper doing syscalls in an exception handler,
		# but this handler is just for demonstration and this keeps it short	
	li $v0, 4	  	#  Use the MARS built-in system call 4 (print string) to print error messsage.
	la $a0, UNHANDLED_EXCEPTION
	syscall 
 	j __resume_from_exception
__overflow_exception:

  	#  Use the MARS built-in system call 4 (print string) to print error messsage.	
	li $v0, 4
	la $a0, OVERFLOW_EXCEPTION
	syscall 
 	j __resume_from_exception
 	
 __bad_address_exception:
  	#  Use the MARS built-in system call 4 (print string) to print error messsage.
	li $v0, 4
	la $a0, BAD_ADRS_EXCEPTION
	syscall
 	j __resume_from_exception	
 
__trap_exception: 
  	#  Use the MARS built-in system call 4 (print string) to print error messsage.
	li $v0, 4
	la $a0, TRAP_EXCEPTION
	syscall
 	j __resume_from_exception

__interrupt: 
	#######################################################
	# >>>>>>>>>>>>>>> ASSIGNMENT PART 3 <<<<<<<<<<<<<<<#
	#######################################################
	# ASSIGNMENT TODO 3: 
	# Value of cause register should already be in $k0. 	
	# Check the pending interrupt bits 
	# for every bit  print "Interrupt x is fired", where x is the 
	# bit number 
	# If the fired interrupt is a keyboard interrupt, 
	# execute the code @ __keyboard_interrupt 

	li $t0, 0x100
	li $t1, 1	# This will be used as a counter for printing the interrupt bit
	
	__check_loop:
		
		beq $t0, 0x10000, __unhandled_interrupt
	
		and $k1, $k0, $t0
		beq $k1, 0x100, __keyboard_interrupt
		sll $t0, $t0, 1 
		
		# Print "Interrupt "
		li $v0, 4
		la $a0, INTERRUPT_MESSAGE
		syscall
		
		# Print Interrupt bit, and iterate the counter
		li $v0, 1
		move $a0, $t1
		addi $t1, $t1, 1
		syscall
		
		# Print "is inactive" if interrupt bit is 0, else print "is fired"
		li $v0, 4
		beq $k1, $zero, __load_inactive
		j __load_fired
		
		
		__load_fired:
			la $a0, INTERRUPT_FIRED
			syscall
			j __check_loop
			
		__load_inactive:
			la $a0, INTERRUPT_INACTIVE
			syscall
			j __check_loop
		

__unhandled_interrupt:    
  	#  Use the MARS built-in system call 4 (print string) to print error messsage.	
	li $v0, 4
	la $a0, UNHANDLED_INTERRUPT
	syscall 
 	j __resume
 	
 	#######################################################
	# >>>>>>>>>>>>>>> ASSIGNMENT PART 4 <<<<<<<<<<<<<<<#
	#######################################################
	# ASSIGNMENT TODO 4: 
 	# Get the ASCII value of pressed key from the memory mapped receiver 
 	# data register. (MMIO tool). Print char to the STDIO uisng a proper syscall. 
 	# Make any unecessary changes in ktext and kdata  to perform this task
__keyboard_interrupt:     	
 	
 	# Getting the received character and printing it
 	li $v0, 11		# Load print character syscall
 	lw $a0, 0xffff0004	# Load character entered by user
 	syscall			# Print the character
 
	j __resume
	

__resume_from_exception: 	 
	# When an exception or interrupt occurs, the value of the program counter 
	# ($pc) of the user level program is automatically stored in the exception 
	# program counter (ECP), the $14 in Coprocessor 0. 
        # Get value of EPC (Address of instruction causing the exception).   
        mfc0 $k0, $14
        
	#Practice TODO 2: Uncomment the following two instructions to avoid
	# executing  the same instruction causing the current exception again.        
        addi $k0, $k0, 4    # Skip offending instruction by adding 4 to the value stored in EPC    
        mtc0 $k0, $14      # Update EPC in coprocessor 0.
__resume:
		# Restore registers and reset processor state
		lw      $v0, save_v0    # Restore $v0 before returning
		lw      $a0, save_a0    # Restore $a0 before returning	
		lw	$t0, save_t0	# Restore $t0 before returning
		lw      $t1, save_t1	# Restore $t1 before returning
		.set    noat            # Prevent assembler from modifying $at
		lw      $at, save_at     # Restore $at before returning
		.set    at
		eret # Use the eret (Exception RETurn) instruction to set $PC to $EPC@C0 
	
