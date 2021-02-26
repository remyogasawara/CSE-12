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
# file message 
# Success message
# Error message: brace mismatch, braces still on stack, invalid argument
#
# .text
# get argument
# open txt file 
# check if it is a valid argument: not more than 20 char and does  
#                                  not start with letter 
# read txt file 
#     buffer if the txt file is too large -- read it again 
# get first char of txt file 
# readLoop: 
#     exit loop when char is null 
#     if char is '(' or '{' or '[':
#        push
#     else if char is ')' or '}' or ']'
#        check the stack
#        if '(' or '{' or '[' is on stack:
#             remove char 
#        else: 
#             mismatch error
# if stack is empty:
#     print sucess message 
# else:
#     print remaining items of the stack
# push:
#    decrease the $sp by 4 
#    put char onto the stack           
# pop: 
#    increase the $sp by 4 
#    take char off of the stack
#
##########################################################################

#####
.data
buffer: .space 128 
fileMessage: .asciiz "You entered the file:\n"
errorRemaining: .asciiz "ERROR - Brace(s) still on stack: " 
errorMismatch: .asciiz "ERROR - There is a brace mismatch: "
index: .asciiz " at index "
invalid: .asciiz "ERROR: Invalid program argument." 
sucessMessage: .asciiz "SUCCESS: There are "
pairs: .asciiz " pairs of braces."
remainingBraces: .asciiz "ERROR - Brace(s) still on stack: " 

.text
# registers: 
# $v0: holds the syscall number 
# $a0: holds the argument 
# $a1: address of output buffer
# $a2: max number of characters in file 
# $s0: holds the contents of the txt file 
# $s1: holds original stack location 
# $t1: holds the temporary byte
# $t2: holds the index number
# $t3: holds the current $sp value

main: 
     NOP 
     li     $v0 4 
     la     $a0 fileMessage 
     syscall
     
     lw     $s0 ($a1)
     move   $a0 $s0
     li     $v0 4
     syscall
     
     # new line 
     li $a0 10
     li $v0 11 
     syscall
     
     # get argument 
     lw      $s0 ($a1)       # move to file descriptor into $s0
     move    $a0 $s0         # move the argument into $a0 
     
     # open file 
     li      $v0 13          # syscall for open file 
     li      $a1 0           # open for reading 
     syscall                 # open file 
     move    $s0 $v0         # saves the file descriptor 
     
     # read file 
     li      $v0 14          # syscall for read file 
     move    $a0 $s0         # reads the file descriptor 
     la      $a1 buffer      # address of buffer from which to write 
     la      $a2 20          # max char length 
     syscall                 # read file 
     
     la      $a0 buffer      # address of buffer 
     li      $v0 4
     move    $s0 $a0         # move the contents of the txt into $s0
     
     # new line 
     li     $a0 10
     li     $v0 11 
     syscall
     
     # store the empty stack
     add $s1 $0 $sp           # store the original stack value 
     
     
     li $s2 0 # pair counter 
     li $t2 0 # stores the index
     textLoop:
          li      $v0 1                    # sycall for ascii integer 
          lb      $a0 ($s0)                # loads the byte into the $a0 register 
          move    $t1 $a0                  # moves to byte to the $t1 register 
          beq     $t1 0     textEnd       # ends the loops if the byte is null 
    
          addi    $s0 $s0 1                # move to the next byte
          addi    $t2 $t2 1                # increase the index 
          
          beq     $t1 40    PUSH           # if '(' push
          beq     $t1 91    PUSH           # if '[' push
          beq     $t1 123   PUSH           # if '{' push
          
          beq     $t1 41    checkStack     # if ')' check if stack is empty or parentheses match 
          beq     $t1 93    checkStack     # if ']' check if stack is empty or brackets match 
          beq     $t1 125   checkStack     # if '}' check if stack is empty or braces match   # if (sp) == $t1   

          j textLoop      
     textEnd:

     seq $t3 $sp $s1
     beq $t3 1 success
     beq $t3 0 remaining
     
     li $v0 10
     syscall               # end of main

success: #prints success message and exits the emptyStack label 
     li $v0 4 
     la $a0 sucessMessage 
     syscall          # prints "There are "
          
     li $v0 1 
     move $a0 $s2
     syscall          # prints number of pairs 
          
     li $v0 4         
     la $a0 pairs 
     syscall          # prints " pairs of braces." 
     
     li      $a0 10
     li      $v0 11 
     syscall               # new line
          
      # end of success 
     li     $v0 10
     syscall

remaining: 
     li $v0 4 
     la $a0 remainingBraces 
     syscall              # "ERROR - Brace(s) still on stack:"
     
     stackLoop:
          beq $sp $s1 stackEnd  # exits when the stack is empty
          lw $a0 ($sp) 
          li $v0 11
          syscall
     stackEnd: 
     
     li      $a0 10
     li      $v0 11 
     syscall               # new line  
        
     # end of remaining  
     li     $v0 10
     syscall
       
          
#################### STACK ####################

# pushes a brace that is in $s0 into the stack 
PUSH: 
     addi $sp $sp   -4    # moves the stack pointer down
     sw   $t1 ($sp)       # moves the byte into the stack   
     j    textLoop  
     
# removes a brace from the stack 
POP:
    lw   $t1 ($sp)       # gets the byte from the stack 
    addi $sp $sp   4     # moves the stack pointer back up 
    addi $s2 $s2   1     # increases the pair count    
    
    j    textLoop    
     
checkStack: # checks the length of the stack
     beq $sp $s1 mismatch
     li $v0 1 
     lw $a0 ($sp) 
     move $t3 $a0 
     
     beq $t1 41  parentheses
     beq $t1 93  brackets 
     beq $t1 125 braces  
     
     parentheses:
          beq $t3 40  POP
          beq $t3 91  mismatch
          beq $t3 123 mismatch 

     brackets:
          beq $t3 40  mismatch
          beq $t3 91  POP
          beq $t3 123 mismatch

     braces:
          beq $t3 40  mismatch
          beq $t3 91  mismatch
          beq $t3 123 POP

     mismatch:
          li     $v0 4 
          la     $a0 errorMismatch 
          syscall                   # print error message  
           
          li     $v0 11
          move   $a0 $t1
          syscall                   # print brace
           
          li     $v0 4 
          la     $a0 index 
          syscall                   # print index
          
          li     $v0 1 
          move   $a0 $t2 
          syscall                   # print index
          
          li      $a0 10
          li      $v0 11 
          syscall               # new line

          # end of mismatch
          li     $v0 10
          syscall    

# end of program
li     $v0 10
syscall 
