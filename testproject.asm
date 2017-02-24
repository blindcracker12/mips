	.data
griddisplay	.ascii	"     ________________________\n"
				.ascii	"    |   |   |   |   |   |   |\n"
				.ascii	"    |   |   |   |   |   |   |\n"
				.ascii	"    |___|___|___|___|___|___|\n"
				.ascii	"    |   |   |   |   |   |   |\n"
				.ascii	"    |   |   |   |   |   |   |\n"
				.ascii	"    |___|___|___|___|___|___|\n"
				.ascii	"    |   |   |   |   |   |   |\n"
				.ascii	"    |   |   |   |   |   |   |\n"
				.ascii	"    |___|___|___|___|___|___|\n"
				.ascii	"    |   |   |   |   |   |   |\n"
				.ascii	"    |   |   |   |   |   |   |\n"
				.asciiz	"    |___|___|___|___|___|___|\n"

uwin		.asciiz "USER WINS!!"
cwin		.asciiz	"COMPUTER WINS!!"
tie		.asciiz	"GRID IS FULL. TIE!! "
colselect		.asciiz "Please select a column= "
colselecterror 	.asciiz "Invalid Column!!...SELECT AGAIN"

word		.word	0		# NOTE: Easier if "grid" byte array 
grid		.space	24		# begins at an address that's a multiple of 4.
grid    .byte	2,1,0,0,1,2,2,1,0,0,1,2,2,1,0,0,1,2,2,1,0,0,1,2     # use to test print_game function
						
againmsg	.asciiz	"PLAY AGAIN (Nonzero=YES, 0=NO)? "
welcome	.asciiz	"WELCOME TO THE MIPSYM VERSION OF CONNECT-4!"
		.code

Main:

	
	
	jal	resetdisplay
	
	jal initialize_grid	
	
	jal	print_game
	
   	jal 	selectcoluser_dropuserpiece

	
	syscall	$exit
	
selectcoluser_dropuserpiece:

		addi $sp,$sp,-20
		sw  $ra,0($sp)
		sw  $a0,4($sp)
		sw  $a1,8($sp)
		sw  $s0,12($sp)
		sw  $s1,16($sp)
	
		la $s0, grid
0:	
		addi $a1,$0,15
		addi $a0,$0,2
	
		syscall $xy
		la $a0,colselect
		syscall $print_string
	
		syscall $print_int
		addi  $t0,$v0,-1
		sltiu  $t1,$t0,6
		beqz  $t1,1f
		add   $s0,$s0,$t0
	
		addi   $s0,$s0,18
		lb     $s1,0,($s0)
		beqz   $s1,2f
	
		addi   $s0,$s0,-6
		lb     $s1,0,($s0)
		beqz   $s1,2f
	
		addi   $s0,$s0,-6
		lb     $s1,0,($s0)
		beqz   $s1,2f
	
		addi   $s0,$s0,-6
		lb     $s1,0,($s0)
		beqz   $s1,2f
1:
		addi $a1,$0,16
		addi $a0,$0,2
		syscall $xy
		la  $a0,colselecterror
		syscall $print_string
		b     0b
	
2:
		addi $s1,$0,1
		sb   $s1,0($s0)
	
		lw  $ra,0($sp)
		lw  $a0,4($sp)
		lw  $a1,8($sp)
		lw  $s0,12($sp)
		lw  $s1,16($sp)
		addi $sp,$sp,20

	
		jr $ra
	
	
	
resetdisplay:
	# function code implementation
	addi		$a0,$0,'\f		# clear screen character
	syscall	$print_char
	
	jr	$ra
	

initialize_grid:
	la $a0,grid
	syscall $print_int
	jr	$ra

	
###############################################################################
# void print_game(void)
#
###############################################################################
# Description: 
# This function prints a 4 row-by-6 column grid onto the console. The grid lines
# are comprised of underscore characters separating the rows, and the vertical
# bar (ASCII byte 0x7C) separating the columns. Each grid cell has a height of
# 3 spaces in the vertical direction, and 3 spaces in the horizontal direction.
# The vertical bars forming the vertical boundaries of cells must be separated 4 spaces 
# from each one another. The underscore characters forming the horizontal boundaries
# of the cells must be separated by 3 rows from one another.
 
# The contents within each grid cell is stored in a 24-byte "grid" byte array. If
# a particular element of the "grid" array contains a value of 0, then the corresponding 
# grid cell is empty, and nothing is visually written into each cell. If an element
# contains a value of 1, then an "O" is placed in the center of a grid cell. If an 
# element contains a value of 2, then an "X" is placed in the center of the grid cell.

###############################################################################
#  Register usage: <list any t0-t9 registers used by the function>
###############################################################################

print_game:
	# move stack pointer
	# put registers onto the stack
	
	addi		$a0,$0,0
	addi		$a1,$0,0
	syscall	$xy
	la		$a0,griddisplay
	syscall	$print_string
	
	addi		$a0,$0,35
	addi		$a1,$0,5
	syscall	$xy
	
	la		$a0,welcome
	syscall	$print_string
	
	# loop through grid array to place Os and Xs onto the console
	
	la		$t0,grid	
	addi		$t1,$0,0	# t1 is the current grid array element number (N) pointed to by t0
						# starting at element 0

printgridloop:
	# must convert t1 (the current grid array element) 
	# to console col and row parameters for syscall $xy

	sltiu	$t2,$t1,6		# check if 0 <= t1 < 6
	beqz	$t2,1f			# t1 is not in range
	addi		$a1,$0,2
	sll		$a0,$t1,2		# a0 = 4 * t1
	addi		$a0,$a0,6		# a0 = a0 + 6
	syscall	$xy				# place cursor at position 
							# (a0,a1) on the console
	b		2f			# do not enter elseif1
1:
	addi		$t3,$t1,-6
	sltiu	$t2,$t3,6		# check if 0 <= t3 < 6
							# i.e. if 6 <= t1 < 12
	beqz	$t2,1f	
	addi		$a1,$0,5
	sll		$a0,$t3,2
	addi		$a0,$a0,6
	syscall	$xy
	b		2f
1:


2:
	# Cursor placed at the appropriate console
	# coordinates
	# Must determine whether to place an "X"
	# or an "O"
	lb		$t2,0($t0)		# Must examine value of t2
							# to see if it is 0, 1, or 2

placeX:

placeO:

	addi		$t0,$t0,1
	addi		$t1,$t1,1
	
	# Determine the condition(s) for branching
	# back to printgridloop

	
	
	# load registers from the stack
	# reset stack pointer
	jr	$ra







	