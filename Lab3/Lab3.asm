##########################################################################
# Created by:  Bhandari, Suneet
#              Sugbhand
#              19 February 2019
#
# Assignment:  Lab 3: ASCII-risks (Asterisks)
#              CSE 012, Computer Systems and Assembly Language
#              UC Santa Cruz, Winter 2020
# 
# Description: This program prints a triangle given from the user Input using tabs and astrerisks to form the triangle.
# 
# Notes:       This program is intended to be run from the MARS IDE.
##########################################################################

# REGISTER USAGE
# $t0: user input (number of rows) 
# $t1: copy of the user input at $t0
# $t2: Outer loop counter (for rows of triangle)
# $t3: numbers printed throughout the triangle
# $t4: Inner loop counter for the tabs before each number in each row
# $t5: Inner loop counter for the numbers being printed and the tabs and asteriks
# $t6: stores value for $t2 - 2 to make subtraction simpler

.data 
	prompt: .asciiz "Enter the height of the triangle (must be greater than 0): "
	newline: .asciiz "\n"
	prompt1: .asciiz "Invalid Entry!"
	tab: .asciiz "\t"
	tab1: .asciiz "\t*\t"
	
.text 
     main: 
	li $v0, 4			#prints the prompt for the user input 
	la $a0, prompt 	
	syscall 
		
	li $v0, 5			#asks for the user input for the triangle
	syscall 
	
	move $t0, $v0
	
     while: 				#loop which makes user enter and positive integer
	bgt $t0, 0, main1 		#if $t0 <= 0 print error message else go the main1 start, creating the triangle
	li $v0, 4
	la $a0, prompt1 		#prints Entry for new triangle row
	syscall
	
	li $v0, 4		
	la $a0, newline			#prints newline
	syscall
	
	li $v0, 4
	la $a0, prompt 			#prints error message
	syscall
	
	li $v0, 5			#calls for the user input of new number for rows
	syscall
	
	move $t0, $v0 
	
	j while
	
     main1: 
     	addi $t1, $t0, 0		#initialize $t1
     	addi $t2, $zero, 0		#initialize $t2
     	addi $t3, $zero, 1     		#initialize $t3
     loop1:
     	bge  $t2, $t0, exit		#if $t2 < $t0 then continue through the loop, else end loop and exit program
     	addi $t4, $t2, 1		#initialize $t4
     	addi $t5, $zero,0		#initialize $t5
	
     loop2:
     	bge $t4, $t0, loop3		#if $t4 < $t0 continue through loop else, go the loop3
     	li $v0, 4			
	la $a0, tab 			#prints each tab for each line before every first number of each line
	syscall
	addi $t4, $t4, 1		#increments $t4
	j loop2				#calls for loop to start over unless condition is not met
	
     loop3:
	bgt $t5, $t2,output		#if $t5 <= $t2 then continue else go to output which is the ending of loop1
	li $v0,1
	move $a0,$t3			#prints integer value for the triangle
	syscall
	addi $t3, $t3,1			#increments $t3
	addi $t5, $t5,1			#increments $t5
	
	ble $t1,$t0,output1		#if statement to only print the tabs and asteriks if $t1>$t0, else go to output1, the end of loop3
	li $v0, 4
	la $a0, tab1 			#prints the tab,asterisk,and then another tab
	syscall
	
     output1:
     
	sub  $t1,$t1,1			#decrement $t1
	j loop3				#calls for loop3 if condtion is not met
	
     output:
	li $v0, 4	
	la $a0, newline			#prints new line at the end of each row
	syscall
	addi $t6,$t2,2			#initialize $t6
	add $t1,$t1,$t6			#adds $t6 to $t1 to make a new $t1
  
	addi $t2, $t2, 1		#increments $t2 the counter for the outer loop
	j loop1
     
     exit:
	li $v0, 10                   	#exits program
        syscall
