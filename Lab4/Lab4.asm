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
.text 

.data 
# registers: 
# $v0: holds the syscall number 
# $a0: 
# $s0: 
