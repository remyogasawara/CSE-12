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
# buffer if the txt file is too large -- read it again 
#     read the first 128 characters 
#     go to readLoop 
#     go back to top of buffer loop, read next 128 characters until done reading
# end buffer loop 
# close file 
# 
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
# endReadLoop
#
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
# end program
#
##########################################################################

.data
buffer: .space 128
fileMessage: .asciiz "You entered the file:\n"
errorMismatch: .asciiz "\nERROR - There is a brace mismatch: "
index: .asciiz " at index "
invalidMessage: .asciiz "\nERROR: Invalid program argument." 
sucessMessage: .asciiz "\nSUCCESS: There are "
pairs: .asciiz " pairs of braces."
remainingBraces: .asciiz "\nERROR - Brace(s) still on stack: " 


.text
# registers: 
# $v0: holds the syscall number 
# $a0: holds the argument 
# $a1: address of output buffer
# $a2: max number of characters in file 
# $s0: holds the file descriptor 
# $s1: holds original stack location
# $s2: holds the contents of the txt file  
# $s3: hold number of characters read

main: 
     NOP 
     li     $v0 4                   # syscall for strings    
     la     $a0 fileMessage         # print the file message 
     syscall                        # prints "You entered the file:"
     
     lw     $s0 ($a1)               # move the argument into $s0 
     move   $a0 $s0                 # move the arugment (file name) into $a0 
     li     $v0 4                   # syscall for strings 
     syscall                        # prints file name
     
     li     $a0 10                  # character for new line 
     li     $v0 11                  # syscall for ascii characters 
     syscall                        # prints a  new line 
  
     li      $v0 1                  # syscall for integers 
     lb      $a0 0   ($s0)          # get the ascii num for first char of file name 
     move    $t1 $a0                # stores first char into $t1
     
     sge     $t2 $t1 97             # if first character is greater or equal to 97 
     sle     $t3 $t1 122            # if first character is less or equal to 122
     and     $t4 $t2 $t3            # return 1 if 97 <= $t1 <= 122
     sge     $t2 $t1 65             # if first character is greater or equal to 65
     sle     $t3 $t1 90             # if first character is less or equal to 90
     and     $t5 $t2 $t1            # return 1 if 65 <= $t1 <= 90
     or      $t6 $t4 $t5            # return 1 if a-z or A-Z
     
     beq     $t6 0 invalid          # if not 97 <= $t1 <= 122 or 65 <= $t1 <= 90, invalid filename 
     nop                            # nop added after the branch instruction     
     li      $t0 0                  # keeps track of how many characters there are 
     checkFile: 
         addi $t0 $t0 1             # increase counter  
         lb   $a0 0($s0)            # loads the character of the file name 
         move $t1 $a0               # moves the character into $t1 
         beq  $t1 0 checkEnd        # end loop when null 
         nop                        # nop added after the branch instruction
         bgt  $t0 20 invalid        # if the file is larger than 20 characters, it is invalid
         nop                        # nop added after the branch instruction         
         sge  $t2 $t1 97            # if first character is greater or equal to 97 
         sle  $t3 $t1 122           # if first character is less or equal to 122
         and  $t4 $t2 $t3           # characters a - z can be part of the file 
         
         sge  $t2 $t1 65            # if first character is greater or equal to 65
         sle  $t3 $t1 90            # if first character is less or equal to 90
         and  $t5 $t2 $t3           # characters A - Z can be part of the file 
         
         sge  $t2 $t1 48            # if first character is greater or equal to 65
         sle  $t3 $t1 57            # if first character is less or equal to 90
         and  $t6 $t2 $t3           # characters 0 - 9 can be part of the file 
         
         seq  $t7 $t1 46            # periods can be part of the file         
         seq  $t8 $t1 95            # underscores can be part of the file
         
         or   $t2 $t4 $t5           # return 1 if a-z or A-Z
         or   $t3 $t2 $t6           # return 1 if a-z or A-Z or 0-9
         or   $t2 $t3 $t7           # return 1 if a-z or A-Z or 0-9 or period 
         or   $t3 $t2 $t8           # return 1 if a-z or A-Z or 0-9 or period or underscore  

         beq $t3 0 invalid          # prints invalid argument message if not a-z or A-Z or 0-9 or period or underscore  
         nop                        # nop added after the branch instruction        
         addi $s0 $s0 1             # move to the next character 
         j checkFile                # checks the next character 
     checkEnd:
     
     # get argument 
     lw      $s0 ($a1)              # move to file descriptor into $s0
     move    $a0 $s0                # move the argument into $a0    
     
     # open file 
     li      $v0 13                 # syscall for open file 
     li      $a1 0                  # open for reading 
     syscall                        # open file 
     move    $s0 $v0                # saves the file descriptor 
     
     add     $s1 $0 $sp             # store the original stack value  
     li      $t4 0                  # pair counter 
     li      $t2 0                  # initialize the index
     bufferLoop: 
          # read file 
          li      $v0 14                # syscall for read file      
          move    $a0 $s0               # reads the file descriptor 
          la      $a1 buffer            # address of buffer from which to write 
          li      $a2 128               # max char length 
          syscall                       # read file 
  
          move    $s3 $v0               # moves number of characaters read to $s0 
          beq     $s3 0   checkStatus 	# is $t3 is 0, check if sucess or braces still on stack
          nop                           # nop added after the branch instruction     
          la      $a0 buffer            # address of buffer 
          move    $s2 $a0               # move the contents of the txt into $s0  
          j textLoop                    # loop through the characters of the text file
    
     bufferEnd:                         # end of buffer loop - done reading file 
     
     closeFile: 
     li   $v0 16                    # system call for close file
     move $a0 $s0                   # file descriptor to close
     syscall                        # close file
     li $v0 10                      # syscall end program 
     syscall                        # end of main

textLoop:
     li      $v0 1                  # sycall for ascii integer 
     lb      $a0 ($s2)              # loads the byte into the $a0 register 
     move    $t1 $a0                # moves to byte to the $t1 register 
     beq     $t1 0     textEnd      # ends the loops if the byte is null 
     nop                            # nop added after the branch instruction               
     addi    $s2 $s2 1              # move to the next byte
   
     beq     $s3 0 bufferLoop       # if $s3 is 0 go to bufferLoop to exit
     nop                            # nop added after the branch instruction               
     addi    $s3 $s3 -1              
               
     beq     $t1 40    PUSH         # if '(' push
     nop                            # nop added after the branch instruction 
     beq     $t1 91    PUSH         # if '[' push
     nop                            # nop added after the branch instruction 
     beq     $t1 123   PUSH         # if '{' push
     nop                            # nop added after the branch instruction 
     beq     $t1 41    checkStack   # if ')' check if stack is empty or parentheses match 
     nop                            # nop added after the branch instruction 
     beq     $t1 93    checkStack   # if ']' check if stack is empty or brackets match 
     nop                            # nop added after the branch instruction 
     beq     $t1 125   checkStack   # if '}' check if stack is empty or braces match   # if (sp) == $t1   
     nop                            # nop added after the branch instruction          
     addi    $t2 $t2 1              # increase the index 
     j textLoop                     # restart the loop 
textEnd:                            # end of test loop 
                        
checkStatus: 
     seq $t3 $sp $s1                # 1 if stack is empty, 0 if braces remaing on stack 
     beq $t3 1 success              # print success message if stack is empty 
     nop                            # nop added after the branch instruction 
     beq $t3 0 remaining            # print remaining braces error message if stack is not empty 
     nop                            # nop added after the branch instruction 
     li $v0 10                      # syscall end program 
     syscall                        # end of checkStatus

# prints success message 
success:           
     li $v0 4                       # syscall for strings
     la $a0 sucessMessage           # puts sucessMessage into $a0 
     syscall                        # prints "There are "
          
     li $v0 1                       # syscall for integers 
     move $a0 $t4                   # moves the number of pairs into $a0 
     syscall                        # prints number of pairs 
          
     li $v0 4                       # syscall for string   
     la $a0 pairs                   # puts pairs message into $a0  
     syscall                        # prints " pairs of braces." 
     
     li      $a0 10                 # new line char 
     li      $v0 11                 # syscall for ascii char 
     syscall                        # prints new line
      
     j closeFile                    # close the file to end program
     li     $v0 10                  # syscall for exit 
     syscall                        # end of success 
     
# prints error message and remain braces on stack 
remaining: 
     li $v0 4                       # syscall for strings
     la $a0 remainingBraces         # print remaining braces message 
     syscall                        # "ERROR - Brace(s) still on stack:"
     
     stackLoop:                     # traverse through what is left on the stack 
          beq $sp $s1 stackEnd      # exits when reach end of stack 
          
          lw $a0 ($sp)              # get element from the stack 
          li $v0 11                 # syscall for ascii char 
          syscall                   # print brace 
          addi $sp $sp 4            # move stack pointer to next char 
          j stackLoop               # restart loop 
     stackEnd:                      # end loop 

     li      $a0 10                 # new line char 
     li      $v0 11                 # syscall for ascii char 
     syscall                        # new line  
     j closeFile                    # close the file to end program
     li     $v0 10                  # syscall for exit
     syscall                        # end of remaining 

# prints error message for an invalid file name 
invalid: 
     li $v0 4                       # syscall for strings 
     la $a0 invalidMessage          # moves ivalid message to $a0 
     syscall                        # prints "ERROR: Invalid program argument." 
     li      $a0 10                 # char for new line 
     li      $v0 11                 # syscall for ascii char 
     syscall                        # new line  
     li     $v0 10                  # syscall for exit 
     syscall                        # end of invalid  
     
#################### STACK ####################
# pushes a $t1 into the stack 
PUSH: 
     addi $sp $sp   -4              # moves the stack pointer down
     sw   $t1 ($sp)                 # moves the byte into the stack   
     addi $t2 $t2 1                 # increase the index counter 
     j    textLoop                  # goes back to traverse the rest of the file  
     
# removes a brace from the stack 
POP:
    lw   $t1 ($sp)                  # gets the byte from the stack 
    addi $sp $sp   4                # moves the stack pointer back up 
    addi $t4 $t4   1                # increases the pair counter     
    addi $t2 $t2 1                  # increase the index counter 
    j    textLoop                   # goes back to traverse the rest of the file    

# checks the length of the stack or if brace matches the one on the stack 
checkStack: 
     beq $sp $s1 mismatch           # the stack is empty, there is a mismatch 
     li $v0 1                       # syscall for integers
     lw $a0 ($sp)                   # load the ascci char of the item on the top of the stack 
     move $t3 $a0                   # move the char into $t3 
     
     beq $t1 41  parentheses        # if the brace we are checking is ')' check for paraentheses on stack 
     nop                            # nop added after the branch instruction 
     beq $t1 93  brackets           # if the brace we are checking is ']' check for brackets on stack 
     nop                            # nop added after the branch instruction 
     beq $t1 125 braces             # if the brace we are checking is '}' check for braces on stack 
     nop                            # nop added after the branch instruction 
     parentheses:               
          beq $t3 40  POP           # remove the '(' from the stack 
          nop                       # nop added after the branch instruction 
          beq $t3 91  mismatch      # braces do not match, print mismatch error 
          nop                       # nop added after the branch instruction 
          beq $t3 123 mismatch      # braces do not match, print mismatch error 
          nop                       # nop added after the branch instruction 
     brackets:
          beq $t3 40  mismatch      # braces do not match, print mismatch error 
          nop                       # nop added after the branch instruction 
          beq $t3 91  POP           # remove the '(' from the stack 
          nop                       # nop added after the branch instruction 
          beq $t3 123 mismatch      # braces do not match, print mismatch error 
          nop                       # nop added after the branch instruction 
     braces:
          beq $t3 40  mismatch      # braces do not match, print mismatch error 
          nop                       # nop added after the branch instruction 
          beq $t3 91  mismatch      # braces do not match, print mismatch error 
          nop                       # nop added after the branch instruction 
          beq $t3 123 POP           # remove the '(' from the stack 
          nop                       # nop added after the branch instruction 
     # there is a mismatch error 
     mismatch:
          li     $v0 4              # syscall for strings 
          la     $a0 errorMismatch  # moves mismatch message into $a0 
          syscall                   # print error message  
          li     $v0 11             # syscall for ascii char 
          move   $a0 $t1            # moves the char into $a0 
          syscall                   # print brace 
          li     $v0 4              # syscall for strings 
          la     $a0 index          # prints the index message 
          syscall                   # prints " at index "
          li     $v0 1              # sycall for integers 
          move   $a0 $t2            # moves the index into $a0 
          syscall                   # print index number 
          li      $a0 10            # new line char 
          li      $v0 11            # syscall for ascii char 
          syscall                   # new line
          j closeFile               # close the file to end program
          li     $v0 10             # syscall for exit 
          syscall                   # end of mismatch 

# end of program
li     $v0 10                       # syscall for exit 
syscall 
