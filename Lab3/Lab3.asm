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
# .data
#	prompt 
# 	erroressage
# .text
# checkValid:
#	prompt
# 	syscall 4
# 	syscall 5 #get input	
#	bgt input, 0, endValid 
#	errorMessage 
#	syscall 4
#	j checkValid 
# endValid: 
#
# counter starts at 0 
# patternLoop: 
#	increase counter
# 	bgt counter, input, patternEnd
#	starCounter starts at 0
#	stars:
#		increase counter
#		bge starCounter, counter, endStars 
#		* (42) 
#		tab (9)
# 		syscall 11
#		j stars
#	endStars:
#	input
#	syscall 1
#	stars loop again
#	j patternLoop 
# patternEnd:  
#	
##########################################################################                           = 
.data # for putting stuf in memory before the code runs 
prompt: .asciiz "Enter the height of the pattern (greater than 0):	"
errorMessage: .asciiz "Invalid Entry!\n" 

.text # tells the computer where the code starts 
# $v0 --- holds the syscall number 
# $a0 --- holds the printed value
# $t0 --- holds the user input
# $t1 --- holds the counter for patternLoop
# $t2 --- holds the counter for starsLoop

# stay in loop until user input is greater than 0 
checkValid: 
	li $v0 4 # set syscall to 4 (string)
	la $a0 prompt # store prompt in $a0 
	syscall # prints the prompt
	
	li $v0 5 # sets syscall to 5 (input) 
	syscall # user's input
	move $t0 $v0 # moves the user input into $t1 

	bgt $t0 0 endValid # if input is greater than 0, exit loop
	
	li $v0 4 # sets syscall to 4 (string) 
	la $a0 errorMessage # store errorMessage in $a0
	syscall # prints errorMessage 
	
	j checkValid # restarts the loop
endValid: # exits the checking loop 

li $t1 0 # counter for patternLoop  
patternLoop:
	addi $t1 $t1 1 # increase the counter for the integer
	bgt $t1 $t0 patternEnd
	li $t2 0 # counter for stars loop
	starsLoop:
		addi $t2 $t2 1 # increase the counter for stars loop 
		bge $t2 $t1 starsEnd
		li $v0 11
		li $a0 42 
		syscall
		
		j starsLoop
	starsEnd: 
	
	li $v0 1 # sets syscall to 1 (ASCII int) 
	move $a0 $t1 # puts the value in $t1 into the print register
	syscall 
	
	li $v0 11 # sets syscall to 11 (ASCII char) 
	li $a0 10 #goes to the next line
	syscall
	j patternLoop # restarts the patternLoop
patternEnd: 

