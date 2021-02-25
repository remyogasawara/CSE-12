#################### STACK ####################
PUSH:
# pushes a brace that is in $s0 into the stack 
addi $sp $sp -4
sw $s0 ($sp) 

move $a0 $s0
li $v0 1
syscall 

## shows the stack works 
li $a0 0x9
li $v0 11
syscall

#addi $s0 $s0 -100

#move $a0 $s0 
#li $v0 1
#syscall 

#li $a0 0x9
#li $v0 11
#syscall

###

POP:
lw $s0 ($sp) 
addi $sp $sp 4

move $a0 $s0
li $v0 1 
syscall 
