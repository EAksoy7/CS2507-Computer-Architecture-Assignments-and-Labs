.globl main
.text
main: 	lw 		$a0, number    	# load n here to calculate n! 
		jal  		fact   		# Call factorial function
		lw 		$a0, number    # loading the first print argument (number)
		move  	$a1,$v0   		# setting the second print argument (factorial result)
		jal 		printResult   	# Call the print function
 		# Nothing would be printed as you need to implement printResult
 		li   		$v0, 10          	# system call for exit
 		syscall              		 # Exit!

fact: 		subu     	$sp,$sp,8     	
		sw       	$ra,4($sp)    	# Save  returr1  address
		sw       	$a0,0($sp)     		# Save  argumer1t  (r1)
		bgtz     	$a0, general      #  Branch  if  n  >  0
		# handling base case code
		li        	$v0,1          	#  Return  1  for 0!
		addiu    	$sp,  $sp,  8     #  Pop  base case stack
		jr      		$ra            	#  Return  base case  to  caller
general:	subu     	$a0,$a0,1      	#  Compute  n  -  1
		jal      	fact           	#  Call  factorial  function
		lw       	$v1,0($sp)     	#  Load  n
		mul       	$v0,$v0,$v1    	#  Compute  fact(n-1)  '  n
		lw       	$ra,  4($sp)   	#  Restore  $ra
		addiu    	$sp,  $sp,  8     #  Pop  general case stack
		jr      		$ra            	#  Return  general case  to  caller

printResult:
# write down your printing function here 

		jr 		$ra 

.data
number:	.word 	3
Str1:  	.ascii   	"\nThe factorial  of " 
Str2: 	.ascii 	" is "
Str3:		.ascii  	" = "

 