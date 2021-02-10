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
# 	print prompt 
# 	get input	
#	input > 0 endValid 
#	print errorMessage 
#	j checkValid 
# endValid:
#
# counter starts at 0 
# patternLoop: 
#	increase counter
# 	counter > input, patternEnd
#	starCounter starts at 0
#	stars:
#		increase counter
#		 starCounter >= counter, endStars 
#		print * (42) 
#		print tab (9)
#		j stars
#	endStars:
#	counter
#	starCounter2 starts at 0
#	stars2:
#		increase counter
#		bge starCounter >= counter, endStars 
#		print * (42) 
#		print tab (9)
#		j stars
#	endStars2:
# 	got to new line
#	j patternLoop 
# patternEnd:  
#	
#	
##########################################################################                           = 
.data # for putting stuf in memory before the code runs 
prompt: .asciiz "Enter the height of the pattern (greater than 0):	"
errorMessage: .asciiz "Invalid Entry!\n" 

.text # tells the computer where the code starts 

# registers: 
# $v0: holds the syscall number 
# $a0: holds the printed value
# $t0: holds the user input
# $t1: holds the counter for patternLoop
# $t2: holds the counter for starsLoops

# gets the input from the user 
# stay in loop until user input is greater than 0 
checkValid:
	nop
	# prompt user 
	li      $v0 4                           # set syscall to 4 (string)
	la      $a0 prompt                      # store prompt in $a0 
	syscall                                 # prints the prompt
	# get user input
	li      $v0 5                           # sets syscall to 5 (input) 
	syscall                                 # user's input
	move    $t0 $v0                         # moves the user input into $t0 
	# check if input is valid
	bgt     $t0 0 endValid                  # if input is greater than 0, exit loop
	nop                                     # nop added after the branch instructiosn 
	li      $v0 4                           # sets syscall to 4 (string) 
	la      $a0 errorMessage                # store errorMessage in $a0
	syscall                                 # prints errorMessage 
	j       checkValid                      # restarts the loop
endValid:                                       # end the checking loop 

# output starts
li $t1 0                                        # initializes counter to 0
patternLoop:
	nop
	addi $t1 $t1 1                          # increase the counter for the integer by 1 
	bgt  $t1 $t0 patternEnd                 # end loop if the counter is larger than the user's input 
	nop                                     # nop after branch instruction 
	# prints asterisks on the left of the integer
	li   $t2 0 				# counter for stars loop
	leftStarsLoop:
		nop
		addi    $t2 $t2 1               # increase the counter for stars loop 
		bge     $t2 $t1 leftStarsEnd    # end loop if the number of stars is greater or equal to the pattern counter 
		nop                             # nop added after the branch instruction 
		li      $v0 11                  # change syscall to 11 (ASCII char) 
		li      $a0 42                  # * character 
		syscall                         # print character 
		li      $a0 9                   # tab character 
		syscall                         # print character 
		j       leftStarsLoop           # restart leftStarsLoop 
	leftStarsEnd:                           # end loop 
	
	# print the integer 
	li      $v0 1                           # sets syscall to 1 (ASCII int) 
	move    $a0 $t1                         # puts the value in $t1 into the print register
	syscall 
	
	#print the asterisks on the right of the integer 
	li   $t2 0                              # counter for stars loop
	rightStarsLoop:
		nop
		addi    $t2 $t2 1               # increase the counter for stars loop 
		bge     $t2 $t1 rightStarsEnd   # end loop if the number of stars is greater or equal to the pattern counter
		nop                             # nop added after the branch instruction 
		li      $v0 11                  # change sycall to 11
		li      $a0 9                   # tab character 
		syscall
		li      $a0 42 	                # * character 
		syscall
		j       rightStarsLoop          # restarts the loop 
	rightStarsEnd:                          # end loop 
	
	# goes to the next line 
	li    $v0 11                            # sets syscall to 11 (ASCII char) 
	li    $a0 10                            # goes to the next line
	syscall

	j patternLoop                           # restarts the patternLoop
patternEnd:                                     # end loop 

# exit program 
li $v0 10 
syscall 