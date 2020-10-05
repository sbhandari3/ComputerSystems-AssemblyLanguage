##########################################################################
# Created by:  Bhandari, Suneet
#              Sugbhand
#              15 March 2019
#
# Assignment:  Lab 5: Functions and Graphics
#              CSE 012, Computer Systems and Assembly Language
#              UC Santa Cruz, Winter 2020
# 
# Description: This program draws in MIPS using the Stack, Arrays, Memory Maps, Subroutines, and Macros to print pixels, lines, rectangles, and triangles
# 
# Notes:       This program is intended to be run from the MARS IDE.
##########################################################################

# REGISTER USAGE 
# $t1: Used to store the origin address
# $t2: Used for coordinates, and the end address
# $t3: stores value which corresponds to the bitmap array value
# $t4: coordinate x0
# $t5: coordinate y0
# $t6: coordinate x1
# $t7: coordinate y1
# $t8: counter value in draw pixel
# $t89: counter value in draw pixel
# $s0: error value
# $s1: loads word from $a0 into this register when opening the file
# $s2: Counter for the number of successes found
# $s4: used to draw trinagle by storing values
# $s5: used to draw trinagle by storing values
# $s6: used to draw trinagle by storing values

# Macro that stores the value in %reg on the stack 
#  and moves the stack pointer.
.macro push(%reg)
	subi $sp, $sp, 4		#stores the bracket in the stack
     	sw %reg, ($sp)
.end_macro 

# Macro takes the value on the top of the stack and 
#  loads it into %reg then moves the stack pointer.
.macro pop(%reg)
	lw %reg ($sp)
	addi $sp $sp 4
.end_macro

# Macro that takes as input coordinates in the format
# (0x00XX00YY) and returns 0x000000XX in %x and 
# returns 0x000000YY in %y
.macro getCoordinates(%input %x %y)
	srl %x, %input, 16			#rotate right
	rol %y, %input, 16			#rotate left
	srl %y, %y, 16				#store value
.end_macro

# Macro that takes Coordinates in (%x,%y) where
# %x = 0x000000XX and %y= 0x000000YY and
# returns %output = (0x00XX00YY)
.macro formatCoordinates(%output %x %y)
	rol %x, %x, 16				#rotates to the left
	add %output, %x, %y			#combines the two
.end_macro 


.data
originAddress: .word 0xFFFF0000
endAddress: .word 0xFFFFFFFC

.text
#li $a0, 0x00400040
#li $a1, 0x00600060
#li $a2, 0x00ffffff
#jal draw_line
j done
    
    done: nop
    li $v0 10 
    syscall

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Subroutines defined below
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#*****************************************************
# clear_bitmap:
#  Given a clor in $a0, sets all pixels in the display to
#  that color.	
#-----------------------------------------------------
# $a0 =  color of pixel
#*****************************************************
clear_bitmap: nop
	lw $t1, originAddress
	lw $t2, endAddress
	
     colormap:
	bgt $t1, $t2, exitloop		#makes sure the memory map covered from top to bottom
	sw $a0, ($t1)
	addi $t1, $t1, 4
	j colormap	
	
     exitloop:
	jr $ra
	
#*****************************************************
# draw_pixel:
#  Given a coordinate in $a0, sets corresponding value
#  in memory to the color given by $a1
#  [(row * row_size) + column] to locate the correct pixel to color
#-----------------------------------------------------
# $a0 = coordinates of pixel in format (0x00XX00YY)
# $a1 = color of pixel
#*****************************************************
draw_pixel: nop
	#push all the registers used
	push $ra
	push $t1
	push $t2
	push $t3
	push $a0
	push $a1
	
	lw $t1, originAddress		#loads originAddress given
	getCoordinates($a0 $t2 $t3)	#gets coordinates 
	mul $t3, $t3, 512		#gets y-coordinate in the proper form
	mul $t2, $t2, 4			#gets x-coordinate in the proper form
	add $t1, $t1, $t2
	add $t1, $t1, $t3
	sw $a1, ($t1)			#draws the pixel on the bitmap
	
	#pops registers to restore value before used
	pop $a1
	pop $a0
	pop $t3
	pop $t2
	pop $t1
	pop $ra
	
	jr $ra
#*****************************************************
# get_pixel:
#  Given a coordinate, returns the color of that pixel	
#-----------------------------------------------------
# $a0 = coordinates of pixel in format (0x00XX00YY)
# returns pixel color in $v0	
#*****************************************************
get_pixel: nop
	#push all the registers used
	push $ra
	push $t1
	push $t2
	push $t3
	push $a0
	push $a1
	
	lw $t1, originAddress		#loads originAddress given
	getCoordinates($a0 $t2 $t3)	#gets coordinates 
	mul $t3, $t3, 512		#gets y-coordinate in the proper form
	mul $t2, $t2, 4			#gets x-coordinate in the proper form
	add $t1, $t1, $t2
	add $t1, $t1, $t3
	lw $v0, ($t1)			#gets the pixel from the bitmap
	
	#pops registers to restore value before used
	pop $a1
	pop $a0
	pop $t3
	pop $t2
	pop $t1
	pop $ra
	
	jr $ra
	

#***********************************************
# draw_line:
#  Given two coordinates, draws a line between them 
#  using Bresenham's incremental error line algorithm	
#-----------------------------------------------------
# 	Bresenham's line algorithm (incremental error)
# plotLine(int x0, int y0, int x1, int y1)
#    dx =  abs(x1-x0);
#    sx = x0<x1 ? 1 : -1;
#    dy = -abs(y1-y0);
#    sy = y0<y1 ? 1 : -1;
#    err = dx+dy;  /* error value e_xy */
#    while (true)   /* loop */
#        plot(x0, y0);
#        if (x0==x1 && y0==y1) break;
#        e2 = 2*err;
#        if (e2 >= dy) 
#           err += dy; /* e_xy+e_x > 0 */
#           x0 += sx;
#        end if
#        if (e2 <= dx) /* e_xy+e_y < 0 */
#           err += dx;
#           y0 += sy;
#        end if
#   end while
#-----------------------------------------------------
# $a0 = first coordinate (x0,y0) format: (0x00XX00YY)
# $a1 = second coordinate (x1,y1) format: (0x00XX00YY)
# $a2 = color of line format: (0x00RRGGBB)
#***************************************************
draw_line: nop
	push $s0
	push $s1
	push $s2
	push $s3
	push $s4
	push $s5
	push $s6
	push $s7
	
	getCoordinates($a0 $t4 $t5)
	getCoordinates($a1 $t6 $t7)
	
	sub $t8, $t6, $t4
	abs $t8, $t8			#absolute value of dx
	
	blt $t4,$t6, set1		#sees if value needed is 1 or -1 for sx
	subi $t9, $zero, 1
     next:
     	sub $s0, $t7, $t5
     	abs $s0, $s0
     	mul $s0, $s0, -1		#neg abs for dy
     	
     	blt $t5, $t7, set2		#sees if value needed is 1 or -1 for sy
     	subi $s1, $zero, 1
     after:
     	add $s2, $t8, $s0		#error value
     while:
     	#push all the registers used
     	push $ra
     	push $t4
     	push $t5
     	push $a0
     	push $a1
     	push $a2
     	
     	formatCoordinates($a0 $t4 $t5)	#formats Coordinates back to the way they were
     	move $a1, $a2
     	jal draw_pixel	
     	
     	#pop all the registers used
     	pop $a2
     	pop $a1
     	pop $a0
     	pop $t5
     	pop $t4
     	pop $ra
     	
     	beq $t4, $t6, check_y
     	b mule2
     	
     check_y: 
     	beq $t5, $t7, exit		#break out of loop
     	b mule2
     mule2:
     	mul $s3, $s2, 2
     	b nextif
     nextif:
     	bge $s3, $s0, ifadd1
     	b nextif1
     nextif1:
     	ble $s3, $t8, ifadd2
     	b while
     
     ifadd1:				#if statment if e2 >= dy
     	add $s2, $s2, $s0
     	add $t4, $t4, $t9
     	b nextif1
     ifadd2:				#if statment if e2 <= dx
     	add $s2, $s2, $t8
     	add $t5, $t5, $s1
     	b while
     exit:
     	pop $s7
	pop $s6
	pop $s5
	pop $s4
	pop $s3
	pop $s2
	pop $s1
	pop $s0
		
	jr $ra
	
	
     set1: 
     	addi $t9, $zero, 1
     	b next
     set2:
     	addi $s1, $zero, 1
     	b after	

#*****************************************************
# draw_rectangle:
#  Given two coordinates for the upper left and lower 
#  right coordinate, draws a solid rectangle	
#-----------------------------------------------------
# $a0 = first coordinate (x0,y0) format: (0x00XX00YY)
# $a1 = second coordinate (x1,y1) format: (0x00XX00YY)
# $a2 = color of line format: (0x00RRGGBB)
#***************************************************
draw_rectangle: nop
	#push all the registers used
	push $ra
	push $t4
	push $t5
	push $t6
	push $t7
	
	getCoordinates($a0 $t4 $t5)
	getCoordinates($a1 $t6 $t7)
	
     rectloop:
     	bgt $t5, $t7, exitloop2		# checks if both the y coordinates are equal to each other
     	#push all the registers used
     	push $ra
     	push $a0
     	push $t4
     	push $t5
     	push $a1
     	push $t6
     	push $t7
     	
     	formatCoordinates($a0 $t4 $t7)
	formatCoordinates($a1 $t6 $t7)
	jal draw_line			#prints horizontal lines from bottom to top
	
	#pops all the registers used
	pop $t7
	pop $t6
	pop $a1
	pop $t5
	pop $t4
	pop $a0
	pop $ra
	
	subi $t7, $t7, 1 		#subtracts so $t7 will eventually equals $t5 to break the loop
	b rectloop
	
     exitloop2:
     	#pops all the registers used
	pop $t7
	pop $t6
	pop $t5
	pop $t4
	pop $ra
	
    
	jr $ra
	
#*****************************************************
#Given three coordinates, draws a triangle
#-----------------------------------------------------
# $a0 = coordinate of point A (x0,y0) format: (0x00XX00YY)
# $a1 = coordinate of point B (x1,y1) format: (0x00XX00YY)
# $a2 = coordinate of traingle point C (x2, y2) format: (0x00XX00YY)
# $a3 = color of line format: (0x00RRGGBB)
#-----------------------------------------------------
# Traingle should look like:
#               B
#             /   \
#            A --  C
#***************************************************	
draw_triangle: nop
	#push all the registers used
	push $ra
	push $s0
	push $s1
	push $s2
	push $s3
	push $s4
	push $s5
	push $s6
	push $s7
	
	move $s4, $a0			#A
	move $s5, $a1			#B
	move $s6, $a2			#C
	move $a2, $a3			#Color of the triangle
	
	la $a0,($s4)			#A to B
	la $a1,($s5)
	#pop all the registers used
	push $s4
	push $s5
	push $s6
	jal draw_line
	#pop all the registers used
	pop $s6
	pop $s5
	pop $s4
	
	la $a0,($s5)			#B to C
	la $a1,($s6)
	#pop all the registers used
	push $s4
	push $s5
	push $s6
	jal draw_line
	#pop all the registers used
	pop $s6
	pop $s5
	pop $s4
	
	la $a0,($s6)			#C back to A
	la $a1,($s4)
	#pop all the registers used
	push $s4
	push $s5
	push $s6 
	jal draw_line
	#pop all the registers used
	pop $s6
	pop $s5
	pop $s4
	
	
	#pop all the registers used
	pop $s7
	pop $s6
	pop $s5
	pop $s4
	pop $s3
	pop $s2
	pop $s1
	pop $s0
	pop $ra
	jr $ra	
	
	
	
