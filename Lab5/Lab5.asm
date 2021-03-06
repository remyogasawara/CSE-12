##########################################################################
# Created by: Ogasawara, Remy
#             rsogasaw
#             3 March 2021
#
# Assignment: Lab 5: Functions and Graphics 
#             CSE 12, Computer Systems and Assembly Language
#             UC Santa Cruz, Winter 2021
#
# Description: In this lab, we implement functions that perform some 
#              primitive graphics operations on a small simulated 
#              display. These functions allow users to change the 
#              background color of the display and draw horizontal and 
#              vertical lines on the display. 
#
# Notes: This program is intended to be run from the MARS IDE and does not
#        display anything when run 
#
##########################################################################
# Psuedocode:  
# getCoordinate 
#     x = srl output by 16  
#     y = andi output by 0xFFFF
# formatCoordiante:
#     x shift left 16
#     or x and y 
# getPixelAddress:  
#     t reg = (y * 128) + x   
#     t reg = t reg * 4
#     output = origin + t reg  
# clear_bitmap:
#     traverse through pixels:
#          draw_pixel(color of clear) 
# draw_pixel:
#     getPixelAddress 
#     store the color into the pixel address 
# get_pixel:
#     getPixelAddress
# draw_verticle_line:
#     traverse bitmap, add y by 1 byte from [0, 128):
#          draw_pixel
# draw_horizontal_line: 
#     traverse bitmpa, add x by 1 byte from [0, 128)
# draw_crosshair:
#     store (x, y) bit to save color 
#     draw horizontal line
#     draw verticle line 
#     recolor (x, y) with old color 
######################################################
# Macros for instructor use (you shouldn't need these)
######################################################

# Macro that stores the value in %reg on the stack 
#	and moves the stack pointer.
.macro push(%reg)
	subi $sp $sp 4
	sw %reg 0($sp)
.end_macro 

# Macro takes the value on the top of the stack and 
#	loads it into %reg then moves the stack pointer.
.macro pop(%reg)
	lw %reg 0($sp)
	addi $sp $sp 4	
.end_macro

#################################################
# Macros for you to fill in (you will need these)
#################################################

# Macro that takes as input coordinates in the format
#	(0x00XX00YY) and returns x and y separately.
# args: 
#	%input: register containing 0x00XX00YY
#	%x: register to store 0x000000XX in
#	%y: register to store 0x000000YY in
.macro getCoordinates(%input %x %y)
        srl  %x %input 16                           # shift 0x00XX00YY to be 0x000000XX and store in %x 
        andi %y %input 0x000000FF                   # only get the last two bytes of 0x00XX00YY 
.end_macro

# Macro that takes Coordinates in (%x,%y) where
#	%x = 0x000000XX and %y= 0x000000YY and
#	returns %output = (0x00XX00YY)
# args: 
#	%x: register containing 0x000000XX
#	%y: register containing 0x000000YY
#	%output: register to store 0x00XX00YY in
.macro formatCoordinates(%output %x %y)
	sll %x      %x 16                               # shift 0x000000XX to be 0x00XX0000 and store in %x
	or  %output %x %y                               # 0x00XX0000 or 0x000000YY to get 0x00XX00YY and store in %output 
.end_macro 

# Macro that converts pixel coordinate to address
# 	output = origin + 4 * (x + 128 * y)
# args: 
#	%x: register containing 0x000000XX
#	%y: register containing 0x000000YY
#	%origin: register containing address of (0, 0)
#	%output: register to store memory address in
.macro getPixelAddress(%output %x %y %origin)
	# YOUR CODE HERE 
	mul %output %y      128                         # 128 * y stored in %output
	add %output %output %x                          # (128 * y) + x stored in %output
	mul %output %output 4                           # (128 * y + x) * 4 stored in %output 
	add %output %origin %output                   # (128 * y + x) * 4 + origin stored in %output 
.end_macro


.data
originAddress: .word 0xFFFF0000

.text
# prevent this file from being run as main
li $v0 10 
syscall

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Subroutines defined below
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#*****************************************************
# Clear_bitmap: Given a color, will fill the bitmap 
#	display with that color.
# -----------------------------------------------------
# Inputs:
#	$a0 = Color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
# $t0: x 
# $t1: y 
clear_bitmap: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
 	lw $t2 originAddress                  # start with the origin, (0,0) 
        #getCoordinates($t2 $t0 $t1)           # initialize rows in $t0 and columns in $t1 
 	li $t0 0x0000FFFF
 	li $t1 0x00000000
 	rows:
 	     bge $t0 128 rowsEnd 
 	     nop
 	     columns:
 	           bge $t1 128 columnsEnd
 	           nop
 	           getPixelAddress($t3 $t0 $t1 $t2)
                   sw $a0 ($t3)
 	           addi $t1 $t1 1 
 	           j columns
 	     columnsEnd: 
 	     addi $t0 $t0 1 
 	     j rows
 	rowsEnd: 
 	jr $ra

#*****************************************************
# draw_pixel: Given a coordinate in $a0, sets corresponding 
#	value in memory to the color given by $a1
# -----------------------------------------------------
#	Inputs:
#		$a0 = coordinates of pixel in format (0x00XX00YY)
#		$a1 = color of pixel in format (0x00RRGGBB)
#	Outputs:
#		No register outputs
#*****************************************************
# $t0: store x 
# $t1: store y 
# $t2: origin 
# $t3: pixel address 
draw_pixel: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
	getCoordinates($a0 $t0 $t1)
	lw $t2 originAddress
	getPixelAddress($t3 $t0 $t1 $t2) 
	sw $a1 ($t3)
	jr $ra
	
#*****************************************************
# get_pixel:
#  Given a coordinate, returns the color of that pixel	
#-----------------------------------------------------
#	Inputs:
#		$a0 = coordinates of pixel in format (0x00XX00YY)
#	Outputs:
#		Returns pixel color in $v0 in format (0x00RRGGBB)
#*****************************************************
# $t0: x register 
# $t1: y register 
# $t2: origin
# $t3: pixel adress  
get_pixel: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
	getCoordinates($a0 $t0 $t1)
	lw $t2 originAddress
	getPixelAddress($t3 $t0 $t1 $t2) 
	lw $v0 ($t3)
	jr $ra

#*****************************************************
# draw_horizontal_line: Draws a horizontal line
# ----------------------------------------------------
# Inputs:
#	$a0 = y-coordinate in format (0x000000YY)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
draw_horizontal_line: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
 	jr $ra


#*****************************************************
# draw_vertical_line: Draws a vertical line
# ----------------------------------------------------
# Inputs:
#	$a0 = x-coordinate in format (0x000000XX)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
draw_vertical_line: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
 	jr $ra


#*****************************************************
# draw_crosshair: Draws a horizontal and a vertical 
#	line of given color which intersect at given (x, y).
#	The pixel at (x, y) should be the same color before 
#	and after running this function.
# -----------------------------------------------------
# Inputs:
#	$a0 = (x, y) coords of intersection in format (0x00XX00YY)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
draw_crosshair: nop
	push($ra)
	push($s0)
	push($s1)
	push($s2)
	push($s3)
	push($s4)
	push($s5)
	move $s5 $sp

	move $s0 $a0  # store 0x00XX00YY in s0
	move $s1 $a1  # store 0x00RRGGBB in s1
	getCoordinates($a0 $s2 $s3)  # store x and y in s2 and s3 respectively
	
	# get current color of pixel at the intersection, store it in s4
	# YOUR CODE HERE, only use the s0-s4 registers (and a, v where appropriate)

	# draw horizontal line (by calling your `draw_horizontal_line`) function
	# YOUR CODE HERE, only use the s0-s4 registers (and a, v where appropriate)

	# draw vertical line (by calling your `draw_vertical_line`) function
	# YOUR CODE HERE, only use the s0-s4 registers (and a, v where appropriate)

	# restore pixel at the intersection to its previous color
	# YOUR CODE HERE, only use the s0-s4 registers (and a, v where appropriate)

	move $sp $s5
	pop($s5)
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	pop($ra)
	jr $ra
