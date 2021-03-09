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
#     y = andi output by 0xFF
#
# formatCoordiante:
#     x shift left 16
#     or x and y 
#
# getPixelAddress:  
#     t reg = (y * 128) + x   
#     t reg = t reg * 4
#     output = origin + t reg  
#
# clear_bitmap:
#     x = 0  
#     rows:
#         branch if x >= 128
#         y = 0
#         columns: 
#             branch if y >= 128
#             get pixelAddress
#             store color in address 
#             y += 1 
#         x += 1 
#
# draw_pixel:
#     getPixelAddress 
#     store the color into the pixel address 
#
# get_pixel:
#     getPixelAddress
#     load pixel address into v0 
#
# draw_verticle_line:
#     x = given x value 
#     y = 0  
#     verticle:
#         branch if y >= 128
#         get pixelAddress
#         store color in address 
#         y += 1 
#
# draw_horizontal_line: 
#     y = given y value 
#     x = 0  
#     horizontal:
#         branch if x >= 128
#         get pixelAddress
#         store color in address 
#         x += 1 
#
# draw_crosshair:
#     store intersection (x, y) bit to save color with get_pixel
#     draw_horizontal_line  
#     draw_verticle_line 
#     move saved color into intersection with draw_pixel 
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
        srl  %x %input 16                               # shift 0x00XX00YY to be 0x000000XX and store in %x 
        andi %y %input 0x000000FF                       # only get the last two bytes of 0x00XX00YY 
.end_macro

# Macro that takes Coordinates in (%x,%y) where
#	%x = 0x000000XX and %y= 0x000000YY and
#	returns %output = (0x00XX00YY)
# args: 
#	%x: register containing 0x000000XX
#	%y: register containing 0x000000YY
#	%output: register to store 0x00XX00YY in
.macro formatCoordinates(%output %x %y)
	sll %output %x      16                          # shift 0x000000XX to be 0x00XX0000 and store in %output
	or  %output %output %y                          # 0x00XX0000 or 0x000000YY to get 0x00XX00YY and store in %output 
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
	add %output %origin %output                     # (128 * y + x) * 4 + origin stored in %output 
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
# registers for each subroutine is defined above each subroutine
#
#*****************************************************
# Clear_bitmap: Given a color, will fill the bitmap 
#	display with that color.
# -----------------------------------------------------
# Inputs:
#	$a0 = Color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
# $t0: x coordinate
# $t1: y coordinate
# $t2: origin
# $t3: pixel address 
clear_bitmap: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
 	lw $t2 originAddress                          # start with the origin, (0,0) 
 	li $t0 0                                      # initialize rows counter to 0
 	rows:                                         # traverse through rows 
 	     bge $t0 128 rowsEnd                      # branch if x >= 128
             nop
             li $t1 0                                 # initialize columns counter to 0
 	     columns:                                 # traverse through columns 
 	           bge $t1 128 columnsEnd             # branch if y >= 128
 	           nop
 	           getPixelAddress($t3 $t0 $t1 $t2)   # get address of (x,y)
                   sw $a0 ($t3)                       # store color in (x,y)
 	           addi $t1 $t1 1                     # increase y value 
 	           j columns                          # restart rows loop
 	     columnsEnd:                              # end columns loop
 	     addi $t0 $t0 1                           # increase x value  
 	     j rows                                   # restart rows loop
 	rowsEnd:                                      # end rows loop 
 	jr $ra                                        # return to register address 

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
	getCoordinates($a0 $t0 $t1)                    # get x and y values of $a0 
	lw $t2 originAddress                           # get origin 
	getPixelAddress($t3 $t0 $t1 $t2)               # get address of (x,y) 
	sw $a1 ($t3)                                   # store color $a1 into pixel at (x,y)
	jr $ra                                         # return to register address 
	
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
# $t3: pixel address  
get_pixel: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
	getCoordinates($a0 $t0 $t1)                    # get x and y values at $a0 
	lw $t2 originAddress                           # get origin 
	getPixelAddress($t3 $t0 $t1 $t2)               # get address of (x,y)
	lw $v0 ($t3)                                   # get contents (color) of (x,y)
	jr $ra                                         # return to register address 

#*****************************************************
# draw_horizontal_line: Draws a horizontal line
# ----------------------------------------------------
# Inputs:
#	$a0 = y-coordinate in format (0x000000YY)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
# $t0: x coordinate
# $t1: y coordinate
# $t2: origin
# $t3: pixel address 
draw_horizontal_line: nop
 	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
 	lw $t2 originAddress                          # start with the origin, (0,0) 
 	li $t0 0                                      # initialize x coordinate to 0
 	move $t1 $a0                                  # move y coordinate into $t1 
 	horizontal:                                   # traverse through rows 
 	     bge $t0 128 horizontalEnd                # branch if x >= 128
             nop
 	     getPixelAddress($t3 $t0 $t1 $t2)         # get address of (x,y)
             sw $a1 ($t3)                             # store color from $a1 in (x,y)
 	     addi $t0 $t0 1                           # increase x value  
 	     j horizontal                             # restart horizontal loop
 	horizontalEnd:                                # end horizontal loop 
 	jr $ra                                        # return to register address 


#*****************************************************
# draw_vertical_line: Draws a vertical line
# ----------------------------------------------------
# Inputs:
#	$a0 = x-coordinate in format (0x000000XX)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
# $t0: x coordinate
# $t1: y coordinate
# $t2: origin
# $t3: pixel address 
draw_vertical_line: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
 	lw $t2 originAddress                          # start with the origin, (0,0) 
 	li $t1 0                                      # initialize x coordinate to 0
 	move $t0 $a0                                  # move y coordinate into $t1 
 	vertical:                                     # traverse through rows 
 	     bge $t1 128 verticalEnd                  # branch if x >= 128
             nop
 	     getPixelAddress($t3 $t0 $t1 $t2)         # get address of (x,y)
             sw $a1 ($t3)                             # store color from $a1 in (x,y)
 	     addi $t1 $t1 1                           # increase x value  
 	     j vertical                               # restart horizontal loop
 	verticalEnd:                                  # end horizontal loop 
 	jr $ra                                        # return to register address 


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
# $a0: holds the (x,y) coordinate 
# $a1: holds the color in 0x00RRGGBB format 
# $s0: stores the 0x00XX00YY
# $s1: stores the 0x00RRGGBB
# $s2: stores the x value 
# $s3: stores the y value 
# $s4: stores the intersection (x,y) 
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
        move $a0 $s0                                  # move the (x,y) coordinate into a0 
	jal get_pixel                                 # outputs the color of the pixel into v0 
        move $s4 $v0                                  # store the current color in s4 
        
	# draw horizontal line (by calling your `draw_horizontal_line`) function
	# YOUR CODE HERE, only use the s0-s4 registers (and a, v where appropriate)
        move $a0 $s3                                  # move y coordinate into a0 
	move $a1 $s1                                  # move color into a1 
	jal draw_horizontal_line                      # draw horizontal line 
	
	# draw vertical line (by calling your `draw_vertical_line`) function
	# YOUR CODE HERE, only use the s0-s4 registers (and a, v where appropriate)
        move $a0 $s2                                  # move x coordinate into a0 
	move $a1 $s1                                  # move color into a1 
	jal draw_vertical_line                        # draw vertical line 
	
	# restore pixel at the intersection to its previous color
	# YOUR CODE HERE, only use the s0-s4 registers (and a, v where appropriate)
        move $a0 $s0                                  # move intersection (x,y) into a0 
	move $a1 $s4                                  # move intersection (x,y) into a0 
	jal draw_pixel                                # recolors intersection to previous color 
	
	move $sp $s5
	pop($s5)
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	pop($ra)
	jr $ra
