##########################################################################
# Created by:  Bhandari, Suneet
#              Sugbhand
#              2 March 2019
#
# Assignment:  Lab 4: Syntax Checker
#              CSE 012, Computer Systems and Assembly Language
#              UC Santa Cruz, Winter 2020
# 
# Description: This program prints errors for incorecct brace mismatches and errors for if the stack is full at the end of a file, as well as the brace successes
# 
# Notes:       This program is intended to be run from the MARS IDE.
##########################################################################

# REGISTER USAGE
# $t0: the program argument text file name 
# $t1: stores the first byte of the program argument file name
# $t2: Counter for if the file name is over 20 characters
# $t3: stores the word from the buffer into this register
# $t4: loads each byte starting from the first one into this register throughout the loop
# $t5: Counter for the index of the bracket that goes into the stack
# $t6: loads the word(character) from the stack
# $t7: loads word from the stack for the index of the character found in $t6
# $t8: stores $v0 to check whether the file is done being read.
# $s0: used for the opening the file
# $s1: loads word from $a0 into this register when opening the file
# $s2: Counter for the number of successes found

#Pseudocode
# This program will check for bracket mismatchs and show the errors or produce the amount of success found in the file
# First check if the file name is correct
# If(first character = a-z or A-Z)
#	continue;
# else
#	exit;
# If(prog argu. > 20 characters or is not ., _, a-z, A-Z, 0-9,)
#	exit;
# else 
#	continue;
# Next open and readfile
# Open file with syscall 13 and read file with syscall 14
# Store character in the file in a buffer 
# Store all open brackets into the stack, while checking if the other characters are the matching closing bracket, and if they are remove the open bracket from the stack
# if( "(,{,[")
#	push to stack;
# 	increment index
# else if ( "),},]")
# 	pop or check for a bracket mismatch
# 	increment index
# else 
#	ignore charcater while still incrementing index
# 
# check the file again to read the next character in the buffer 
# after, check if the stack is empty or not, 
# if(stack is empty)
#	print successes
# else 
# 	print stack error and all the characters in the stack
# Finally, print newline, close file, and exit program


.data 
	enter: .asciiz "You entered the file: \n"
	newline: .asciiz "\n"
	invalid: .asciiz  "ERROR: Invalid program argument."
	buffer: .space 128
	ati: .asciiz " at index "
	error: .asciiz "ERROR - "
	thereis: .asciiz "There is a brace mismatch: "
	space: .asciiz " "
	onstack: .asciiz "Brace(s) still on stack: "
	success: .asciiz "SUCCESS: "
	thereare: .asciiz "There are "
	pairs: .asciiz " pairs of braces."
	
.text

	move $fp, $sp			#checks if the stack is empty or not
	move $s1, $a1			# moves the content of $a1 into $s1
	
	addi $t5, $zero, 0		#index for the counter that goes into the stack
	addi $s2, $zero, 0		#success counter
	
     main:
 	li $v0, 4			#prints the enter from data which is a string
	la $a0, enter
	syscall 
	
	lw $a0,($a1)			#prints the program argument name
	li $v0,4
	syscall 
	
	li $v0, 4			#prints a newline
	la $a0, newline
	syscall
	
	li $v0, 4			#prints another newline
	la $a0, newline
	syscall
	
	move $s1, $a1			#loads the first character(byte) into a register
	lw $t0,($a1)
	lb $t1, ($t0)
	addi $t2, $zero, 0
	
	j check
	
     check:				#checks if the first character is a alphabetical character or not 
     	blt $t1 65 errorexit
     	bge $t1 65 check1		#Uses ASCII character values to compare with the byte
     	
     check1: 
     	ble $t1, 90, continue		#moves to the next part of file checking
     	bgt $t1, 90, check2		#checks if the first character is a alphabetical character or not
     	
     check2:
     	ble $t1, 96, errorexit		#exits for incorrect file name
     	bgt $t1, 96, check3		#checks if the first character is a alphabetical character or not
     	
     check3: 
     	ble $t1, 122, continue		#moves to the next part of file checking
     	bgt $t1, 122, errorexit		#exits for incorrect file name
     	
     continue:	
     	beq $t2 21, errorexit		#exits for incorrect file name
     	beq $t1, 0, openfile		#opens the file that the program argument says to
     	blt $t1, 46, errorexit		#exits for incorrect file name
     	beq $t1, 46, continue1		#moves to the next part of file checking
     	beq $t1, 47, errorexit		#exits for incorrect file name
     	blt $t1, 58, continue1		#moves to the next part of file checking
     	bgt $t1, 57, check4
     	
     check4:
     	blt $t1, 65, errorexit		#exits for incorrect file name
     	blt $t1, 91, continue1		#moves to the next part of file checking
     	beq $t1, 95, continue1		#moves to the next part of file checking
     	blt $t1, 97, errorexit		#exits for incorrect file name
     	blt $t1, 123, continue1		#moves to the next part of file checking
     	bgt $t1, 122, errorexit		#exits for incorrect file name
     	
     	
     continue1:
     	addi $t0, $t0, 1		#increments counter
     	addi $t2, $t2, 1		#increments counter 
     	lb $t1, ($t0)			#loads next byte
     	j continue			#continues through the whole file name
     
     
     
     openfile:
     	lw $a0, ($s1)			#Opens the file
	li $a1, 0
	li $a2, 0
	li $v0, 13
	syscall
	move $s0, $v0
	
     readfile:				#Reads the contents of the file
	li $v0, 14
	move $a0, $s0
	la $a1, buffer		
	li $a2, 128
	syscall
	
	la $t3, buffer			#moves contents into the buffer
	move $t8, $v0			#move $v0(the amount of characters read) in to $t8
	#move $t9, $v0
	#addi $s3, $zero, 0
	
	#li $v0, 1			#prints the wnter for the user input 
	#la $a0, ($t8)
	#syscall
	
	beq $t8, 0, loop2		#if $t8 is zero check for successes and anything left of the stack
	
	b loop1
	
     loop1:
     	lb $t4,($t3)			#loads first character into register
     	
     	beq $t8, 0, readfile 
 	
 	subi $t8, $t8, 1		#decrements the counter
 	#beq $t4, 0, loop2
     	
     	beq $t4, 40, pushbracket	#pushes if opening bracket
     	beq $t4, 91, pushbracket
     	beq $t4, 123, pushbracket
     	
     	beq $t4, 41, pop1		#pops if closing bracket
     	beq $t4, 93, pop2
     	beq $t4, 125, pop3
     
     	addi $t3, $t3, 1		#increments index
     	addi $t5, $t5, 1		#increments index
     	
     	j loop1				#loops for all the characters read
     	
     pushbracket:
     	subi $sp, $sp, 4		#stores the bracket in the stack
     	sw $t4, ($sp)
     	subi $sp, $sp, 4		#stores the index into the stack
     	sw  $t5, ($sp)
     	
     	addi $t3, $t3, 1		#increments index
     	addi $t5, $t5, 1		#increments index
     	j loop1				#loops to read next character
     
     
     pop1:
     	lw $t6, 4($sp)
     	bne $t6, 40, mismatch		#checks for mismatch
     	
     	addi $t3, $t3, 1		#increments index
     	addi $t5, $t5, 1		#increments index
     	addi $s2, $s2, 1		#increments successes
     	addi $sp, $sp,8			#deletes from stack
     	j loop1
     	
     pop2:
     	lw $t6, 4($sp)
     	bne $t6, 91, mismatch		#checks for mismatch
     	
     	addi $t3, $t3, 1		#increments index
     	addi $t5, $t5, 1		#increments index
     	addi $s2, $s2, 1		#increments success
     	addi $sp, $sp,8			#deletes from stack
     	j loop1
     		
     pop3:
     	lw $t6, 4($sp)
     	bne $t6, 123, mismatch		#checks for mismatch
     	
     	addi $t3, $t3, 1		#increments index
     	addi $t5, $t5, 1		#increments index
     	addi $s2, $s2, 1		#increments success
     	addi $sp, $sp,8			#deletes from stack
     	j loop1
     
     mismatch: 				#prints the mismatches and the indexs from the stack 
        beq $sp, $fp, mismatch2		#checks if stack is empty
     	li $v0, 4			
	la $a0, error
	syscall
	
	li $v0, 4		
	la $a0, thereis
	syscall
	
	li $v0, 11
	la $a0, ($t6)
	syscall 
	
	li $v0, 4			
	la $a0, ati
	syscall
	
	lw $t7, 0($sp)			#loads index from the stack
	li $v0, 1			
	la $a0, ($t7)
	syscall
	
	li $v0, 4			
	la $a0, space
	syscall
	
	li $v0, 11			 #loads bracket from the stack
	la $a0, ($t4)
	syscall
	
	#li $v0, 1			 
	#la $a0, ($t7)
	#syscall
	
	li $v0, 4			
	la $a0, ati
	syscall
	
	li $v0, 1			
	la $a0, ($t5)
	syscall
	
	b exit
	
     mismatch2:				#prints second type of mismatch when the stack is empty and a closing bracket appears
     	li $v0, 4			 
	la $a0, error
	syscall
	
	li $v0, 4			
	la $a0, thereis
	syscall
	
	li $v0, 11			 
	la $a0, ($t4)
	syscall
	
	li $v0, 4			
	la $a0, ati
	syscall
	
	li $v0, 1			
	la $a0, ($t5)
	syscall
	
	b exit
     		
     loop2:
     	bne $sp, $fp, printerror	#if stack is not empty print stack error and every bracket in the stack
     	
     	li $v0, 4			#prints the amount of successes
	la $a0, success
	syscall
	
	li $v0, 4			
	la $a0, thereare
	syscall
	
	li $v0, 1			
	la $a0, ($s2)
	syscall
	
	li $v0, 4			
	la $a0, pairs
	syscall
	
	b exit				#exits
     	
     	
     printerror:
     	li $v0, 4			#prints the wnter for the user input 
	la $a0, error
	syscall
	
	li $v0, 4			#prints the wnter for the user input 
	la $a0, onstack
	syscall	
	
	b printstack			#print stack branch
	
     printstack:
     	bne $sp, $fp, printstack1	#checks if the stack is not empty 
     							
     	b exit				# if empty exit the program
     	
     printstack1:
     	lw $t6, 4($sp)
     	li $v0, 11			#prints the wnter for the user input 
	la $a0,($t6)
	syscall
	
	addi $sp, $sp, 8		#deletes the previous value from the stack 
	
	j printstack			#loops to stack if it is not empty and checks again after printing the value in the stack
     
     errorexit:
     	li $v0, 4			#prints error for an incorrect file name 
	la $a0, invalid
	syscall
	
	b exit
        
     exit: 
     	li $v0, 4			#prints newline
	la $a0, newline
	syscall 
	
	la $a0, ($s0)
	li $v0, 16                   	#close file
        syscall
	
     	li $v0, 10                   	#exits program
        syscall
