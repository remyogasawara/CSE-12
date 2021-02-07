##########################################################################
# Created by: Ogasawara, Remy
#	      rsogasaw
# 	      6 February 2021
#
# Assignment: Lab 3: ASCII-risks (Asterisks)
# 	      CSE 12, Computer Systems and Assembly Language
# 	      UC Santa Cruz, Winter 2021
#
# Description: This program prints out a pattern with numbers and stars.
#	       The user will prompt the height. 
#
# Notes: This program is intended to be run from the MARS IDE.
##########################################################################
# Psuedocode:  
#
#
#
#
#
##########################################################################
# Notes:
# move $t1 $t2 --- moves (make a copy) of the value in $t2 and put inot $t1
# li $t1 5 --- (load immediate) stores 5 in $t1 
# la $t1 label --- (load address) put the label into the register $t1
# beq $t2 5 label --- if $t2 is equal to 5, then go to label 
#		      (inverted) if $t2 is not equal to 5, then go to label 
# bne -- branch if not equal to 
# nop -- null operation, puts an empty space 
# dec 42                                = 
.data # for putting stuf in memory before the code runs 
text: .asciiz "Hello World!"

.text # tells the computer where the code starts 
### practice for loop
# $a0 --- holds the printed value 
# $v0 --- holds the syscall number 
#li $t1 0
# ble $t1 10 forLoopdody # go to label if still need to execute 
#loopstart:
#	bge $t1 10 printLoopEnd # go to label if done 
#	move $a0 $t1    # move what you want to print into $a0
#	li $v0 1 	# prep syscall to print integer
#	syscall 	# prints integer 
#	addi $t1 $t1 1 # $t1 = $t1 + 1
#	j loopstart
#	nop
#	li $t2 6
#printLoopEnd:
#li $v0 4
#la $a0 text 
#syscall 
###

























