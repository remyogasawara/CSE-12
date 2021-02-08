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
# starLoop: 
#	
#	syscall 5 
# donePrinting:
##########################################################################                           = 
.data # for putting stuf in memory before the code runs 
prompt: .asciiz "Enter the height of the pattern (greater than 0):	"
errorMessage: .asciiz "Invalid Entry!\n" 

.text # tells the computer where the code starts 
# $v0 --- holds the syscall number 
# $a0 --- holds the printed value
# $t1 --- holds the user input

# stay in loop until user input is greater than 0 
checkValid: 
	li $v0 4 # set syscall to 4 (string)
	la $a0 prompt # store prompt in $a0 
	syscall # prints the prompt
	
	li $v0 5 # sets syscall to 5 (input) 
	syscall # user's input
	move $t1 $v0 # moves the user input into $t1 

	bgt $t1 0 endValid # if input is greater than 0, exit loop
	
	li $v0 4 # sets syscall to 4 (string) 
	la $a0 errorMessage # store errorMessage in $a0
	syscall # prints errorMessage 
	
	j checkValid # restarts the loop
endValid: # exits the checking loop 

