##########################################################################
# Created by: Ogasawara, Remy
#             rsogasaw
#             18 February 2021
#
# Assignment: Lab 4: Syntax Checker 
#             CSE 12, Computer Systems and Assembly Language
#             UC Santa Cruz, Winter 2021
#
# Description: This program opens a .txt file and determines whether it 
#              has balanced braces, brackets, and parentheses using MIPS 
#              and stack. It will also report either the location of the 
#              mismatch or the number of matched items on success. 
#
# Notes: This program is intended to be run from the MARS IDE and imports 
#        .txt files using arguments
#
##########################################################################
# Psuedocode:  
# .data 
# buffer 
# Success message
# Error message: brace mismatch, braces still on stack 
#
# .text
# needs a buffer 
# traverse through the text from argument
#    if char is '(' or '{' or '[':
#        push
#    else if char is ')' or '}' or ']'
#        if stack is empty of top of stack does not parir with char 
#             return error, type of brace and index
#        else
#
##########################################################################
.data
buffer: .space 128 

.text
# registers: 
# $v0: holds the syscall number 
# $a0: holds the argument 
# $a1: address of output buffer
# $a2: max number of characters in file 
# $s0: holds the file descriptor 

NOP 
# get argument 
lw      $s0 ($a1)       # move to file descriptor into $s0
move    $a0 $s0         # move the argument into $a0 

# open file 
li      $v0 13          #syscall for open file 
li      $a1 0           # open for reading 
syscall                 # open file 
move    $s0 $v0         # saves the file descriptor 

# read file 
li      $v0 14          # syscall for read file 
move    $a0 $s0         # reads the file descriptor 
la      $a1 buffer      # address of buffer from which to write 
la      $a2 20          # max char length 
syscall                 # read file 


# print file contents 
li      $v0 4           # print string syscall 
la      $a0 buffer      # address of buffer 
syscall                 # prints the contents of the txt file 
move    $s0 $a0         # move the contents of the string 

# new line 
li $a0 10
li $v0 11 
syscall

######### printing characters 
# print char 
lb $a0 0($s0)
li $v0 11
syscall 

# print tab 
li $a0 0x9
li $v0 11
syscall

# print char 
lb $a0 1($s0)
li $v0 11
syscall 

# print tab 
li $a0 0x9
li $v0 11
syscall

# print char 
lb $a0 2($s0)
li $v0 11
syscall 

# new line 
li $a0 10
li $v0 11 
syscall
###########

# close file  
li     $v0 16           # sycall for close file 
move   $a0 $s0          # file desriptor to close 
syscall                 # close file 

# end program
li     $v0 10
syscall 
