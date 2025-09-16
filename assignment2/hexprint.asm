.data
	result: .space 2


.text

	addiu $s0, $s0, 133


	li $t0, 2
	la $t1, result
	ror $s0, $s0, 8
	
Loop:
	beqz $t0, Exit
	rol $s0, $s0, 4
	and $t2, $s0, 0xf
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
	
	li $v0, 10
	syscall