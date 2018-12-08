.data
# syscall constants
PRINT_STRING            = 4
PRINT_CHAR              = 11
PRINT_INT               = 1
NEW_LINE:               .asciiz "\n"
SPACE_LINE:             .asciiz "-"
treasure_print:         .asciiz "There is a treasure\n"

# memory-mapped I/O
VELOCITY                = 0xffff0010
ANGLE                   = 0xffff0014
ANGLE_CONTROL           = 0xffff0018

BOT_X                   = 0xffff0020
BOT_Y                   = 0xffff0024

TIMER                   = 0xffff001c

RIGHT_WALL_SENSOR 		= 0xffff0054
PICK_TREASURE           = 0xffff00e0
TREASURE_MAP            = 0xffff0058
MAZE_MAP                = 0xffff0050

REQUEST_PUZZLE          = 0xffff00d0
SUBMIT_SOLUTION         = 0xffff00d4

BONK_INT_MASK           = 0x1000
BONK_ACK                = 0xffff0060

TIMER_INT_MASK          = 0x8000
TIMER_ACK               = 0xffff006c

REQUEST_PUZZLE_INT_MASK = 0x800
REQUEST_PUZZLE_ACK      = 0xffff00d8

ALL_VALUES 		= 0xffff
# struct spim_treasure
#{
#    short x;
#    short y;
#    int points;
#};
#
#struct spim_treasure_map
#{
#    unsigned length;
#    struct spim_treasure treasures[50];
#};
.data
####################### all the data segment code goes here ###############
.align 4
puzzle:                 .word 128
treasure_map:           .word 101

###########################################################################

.text
###########################################################################
#                     self-defined functions 		                      #
###########################################################################


#function: solved(&board):
#>>>>>>> baedde5f64aa1982a7e006a1970069ec76f07641
#  do {
#    changed = rule1(board);
#    changed |= rule2(board);
#  } while (changed);
solved:
	sub	$sp, $sp, 12
	sw	$s0, 0($sp)
	sw	$ra, 4($sp)

	sw	$a0, 8($sp)
loop:
	lw	$a0, 8($sp)
	jal	rule1		#rule1
#	move	$s0,$v0	#changed = $s0 = rule1(board)
	
	jal	rule2		#rule2
	jal	rule1	
#	or	$s0, $s0, $v0
#	beq	$s0, 1, loop
solved_end:
#=======
	sw	$a0, 8($sp)	
	lw	$s0, 0($sp)
	lw	$ra, 4($sp)
	lw	$a0, 8($sp)
	add	$sp, $sp, 12
	jr	$ra 

# this function in C code: bool find_has_treasure(int x, int y);
# take in two parameters x and y, which are spimbot current location and return
# whether current location has treasure. 1 if has 0 if there is no treasure.

# while (lo <= hi) {
#     m = (lo + hi) / 2;
#     if (arr[m].x == x && arr[m].y == y)
#         return m;
#     if (arr[m].x < x || (arr[m].x == x && arr[m].y < y))
#         lo = m + 1;
#     if (arr[m].x > x || (arr[m].x == x && arr[m].y > y))
#         hi = m - 1;
# }
# return - 1
# binary_search:
#         sub        $sp, $sp,                                # allocate memory
#         sw         $ra, 0($sp)                              # store $ra and free up some $s register
#         sw         $s0, 4($sp)
#         sw         $s1, 8($sp)
#         sw         $s2, 12($sp)
#         sw         $s3, 16($sp)
#         move       $s0, $a0                                 # s0 = treasure_array
#         move       $s1, $a1                                 # s1 = lo
#         move       $s2, $a2                                 # s2 = hi
#
# binary_search_loop:
#         bgt        $s1, $s2, binary_search_return           # lo > hi
#         add        $s3, $s1, $s2                            # lo + hi
#         div        $s3, $s3, 2                              # (lo + hi) / 2


find_has_treasure:
        sub        $sp, $sp, 36                             # allocate memory
        sw         $ra, 0($sp)                              # store $ra and free up some $s register
        sw         $s0, 4($sp)
        sw         $s1, 8($sp)
        sw         $s2, 12($sp)
        sw         $s3, 16($sp)
        sw         $s4, 20($sp)
        sw         $s5, 24($sp)
        sw         $s6, 28($sp)
        sw         $s7, 32($sp)

        # move       $s6, $a0
        #
        # li         $v0, PRINT_INT
        # move       $a0, $a1
        # syscall
        # li         $v0, PRINT_STRING
        # la         $s7, SPACE_LINE                         those commented code is used for debug
        # move       $a0, $s7
        # syscall
        #
        # li         $v0, PRINT_INT
        # move       $a0, $s6
        # syscall
        # li         $v0, PRINT_STRING
        # la         $s7, NEW_LINE
        # move       $a0, $s7
        # syscall

        la         $s0, treasure_map                        # load the memory address of treasure map to s0
        sw         $s0, TREASURE_MAP($0)                    # load the treasure map
        lw         $s1, 0($s0)                              # s0 = length of treasure array
        add        $s0, $s0, 4                              # s0 = treausre[length]
        li         $s2, 0                                   # the counter for treasure map loop
        li         $s7, 0
        sw         $s7, VELOCITY($0)
check_treasure_loop:
        bge        $s2, $s1, end_check_treasure_loop        # i >= length of treausre array
        mul        $s3, $s2, 8
        add        $s3, $s0, $s3                            # s3 = &treasure[i]
        lhu        $s4, 0($s3)                              # s4 = treasure[i].row
        lhu        $s5, 2($s3)                              # s5 = treasure[i].col
        sub        $s4, $a0, $s4                            # s4 = botX - treasure[i].row
        sub        $s5, $a1, $s5                            # s5 = botY - treasure[i].col
        or         $s4, $s4, $s5                            # s4 = s4 | s5
        bne        $s4, $0, increment                       # if (botX != treasure[i].x || botY != treasure[i].y) go increment
        # move       $s7, $a0
        # li         $v0, PRINT_STRING
        # la         $a0, treasure_print
        # syscall
        # move       $a0, $s7
        sw         $s3, PICK_TREASURE($0)                   # pick up treasure
        j          end_check_treasure_loop
increment:
        add        $s2, $s2, 1                              # i++
        j          check_treasure_loop

end_check_treasure_loop:
        lw         $ra, 0($sp)                              # restore ra and other registers
        lw         $s0, 4($sp)
        lw         $s1, 8($sp)
        lw         $s2, 12($sp)
        lw         $s3, 16($sp)
        lw         $s4, 20($sp)
        lw         $s5, 24($sp)
        lw         $s6, 28($sp)
        lw         $s7, 32($sp)
        add        $sp, $sp, 36                             # delocate memory
        jr         $ra                                      # return

###########################################################################
#                       The rule 1 they give us                           #
###########################################################################
## bool
## rule1(unsigned short board[GRID_SQUARED][GRID_SQUARED]) {
##   bool changed = false;
##   for (int i = 0 ; i < GRID_SQUARED ; ++ i) {
##     for (int j = 0 ; j < GRID_SQUARED ; ++ j) {
##       unsigned value = board[i][j];
##       if (has_single_bit_set(value)) {
##         for (int k = 0 ; k < GRID_SQUARED ; ++ k) {
##           // eliminate from row
##           if (k != j) {
##             if (board[i][k] & value) {
##               board[i][k] &= ~value;
##               changed = true;
##             }
##           }
##           // eliminate from column
##           if (k != i) {
##             if (board[k][j] & value) {
##               board[k][j] &= ~value;
##               changed = true;
##             }
##           }
##         }
##
##         // elimnate from square
##         int ii = get_square_begin(i);
##         int jj = get_square_begin(j);
##         for (int k = ii ; k < ii + GRIDSIZE ; ++ k) {
##           for (int l = jj ; l < jj + GRIDSIZE ; ++ l) {
##             if ((k == i) && (l == j)) {
##               continue;
##             }
##             if (board[k][l] & value) {
##               board[k][l] &= ~value;
##               changed = true;
##             }
##           }
##         }
##       }
##     }
##   }
##   return changed;
## }

.globl rule1
rule1:
	li 		$v0, 0   					# bool changed = false;
	li 		$s0, 0						# int i = 0;
	sub 	$sp, $sp, 12				# allocate memory for $ra, $a0, $v0
	sw 		$ra, 0($sp)					# store $ra
	sw 		$a0, 4($sp)					# store $a0

outter_loop:
	bge 	$s0, 16, end				# i >= GRID_SQUARED;
	li 		$s1, 0						# j = 0;

first_inner_loop:
	bge 	$s1, 16, end_1st_inner_loop # j >= GRID_SQUARED;
	mul 	$t0, $s0, 16				# i * GRID_SQUARED
	add 	$t0, $t0, $s1				# i * GRID_SQUARED + j
	mul		$t0, $t0, 2					# (i * GRID_SQUARED + j) * 2
	add 	$t0, $a0, $t0				# &board[i][j];
	lhu 	$s7, 0($t0)					# value = board[i][j]
	sw 		$v0, 8($sp)					# store $v0
	move 	$a0, $s7					# $a0 = value
	jal 	has_single_bit_set			# has_single_bit_set(value)
	lw		$a0, 4($sp)					# restore $a0
	beq 	$v0, 1, elimination 		# has_single_bit_set(value) == true
	lw 		$v0, 8($sp)					# restore $v0
	add 	$s1, $s1, 1					# j++
	j		first_inner_loop 			# do first_inner_loop iteration

elimination:
	lw 		$v0, 8($sp)					# restore $v0
	li 		$s2, 0						# k = 0

second_inner_loop:
	bge 	$s2, 16, end_2nd_inner_loop # k >= GRID_SQUARED;
	bne 	$s2, $s1, eliminate_row 	# if (k != j) eliminate_row
keep_going:
	bne 	$s2, $s0, eliminate_column  # if (k != i) eliminate_column
	add  	$s2, $s2, 1					# k++;
	j 		second_inner_loop

end_1st_inner_loop:
	add 	$s0, $s0, 1 				# i++;
	j 		outter_loop					# do outter_loop iteration again

end_2nd_inner_loop:
	move 	$a0, $s0 					# (i)
	sw 		$v0, 8($sp)					# store $v0;
	jal 	get_square_begin			# get_square_begin(i)
	move 	$s2, $v0					# $s2 = k = ii = get_square_begin(i);
	move 	$a0, $s1 					# (j)
	jal 	get_square_begin			# get_square_begin(j)
	move 	$s3, $v0					# $s3 = jj = get_square_begin(j);
	lw 		$a0, 4($sp)					# restore $a0
	lw 		$v0, 8($sp)					# restore $v0
	add 	$s4, $s2, 4					# $s4 = ii + GRIDSIZE
	add 	$s5, $s3, 4					# $s5 = jj + GRIDSIZE

last_nest_loop_out:
	bge 	$s2, $s4, finish_end_loop 	# k >= ii + GRIDSIZE
	move 	$s6, $s3					# l = jj

last_nest_loop_in:
	bge 	$s6, $s5, finish_end_inloop	# l >= jj + GRIDSIZE
	sub 	$t0, $s2, $s0 				# s2 - s0 == k - i
	sub 	$t1, $s6, $s1 				# s6 - s1 == l - j
	or 		$t1, $t0, $t1				# or(k - i && l - j)
	beq		$t1, $0, skip				# if ((k == i) && (l == j))
	mul 	$t0, $s2, 16				# k * GRID_SQUARED
	add 	$t0, $t0, $s6				# k * GRID_SQUARED + l
	mul		$t0, $t0, 2					# (k * GRID_SQUARED + l) * 2
	add 	$t0, $a0, $t0				# &board[k][l];
	lhu 	$t1, 0($t0)					# $t1 = board[k][l];
	and     $t2, $s7, $t1				# $t2 = $t1 & value
	beq 	$t2, $0, skip  				# board[k][l] & value = 0
	nor 	$t2, $s7, $0				# $t2 = ~value
	and 	$t1, $t1, $t2				# $t1 = board[k][l] & ~value
	sh 		$t1, 0($t0)					# board[k][l] &= ~value
	li 		$v0, 1						# chanegd = true;
skip:
	add 	$s6, $s6, 1					# l++
	j 		last_nest_loop_in

finish_end_inloop:
	add 	$s2, $s2, 1					# k++
	j 		last_nest_loop_out

finish_end_loop:
	add 	$s1, $s1, 1					# j++
	j 		first_inner_loop

eliminate_row:
	mul 	$t0, $s0, 16				# i * GRID_SQUARED
	add 	$t0, $t0, $s2				# i * GRID_SQUARED + k
	mul		$t0, $t0, 2					# (i * GRID_SQUARED + k) * 2
	add 	$t0, $a0, $t0				# &board[i][k];
	lhu 	$t1, 0($t0)					# $t1 = board[i][k];
	and     $t2, $s7, $t1				# $t2 = $t1 & value
	beq 	$t2, $0, keep_going  		# board[i][k] & value = 0
	nor 	$t2, $s7, $0				# $t2 = ~value
	and 	$t1, $t1, $t2				# $t1 = board[i][k] & ~value
	sh 		$t1, 0($t0)					# board[i][k] &= ~value
	li 		$v0, 1						# chanegd = true;
	j 		keep_going					# go to next if;

eliminate_column:
	mul 	$t0, $s2, 16				# k * GRID_SQUARED
	add 	$t0, $t0, $s1				# k * GRID_SQUARED + j
	mul		$t0, $t0, 2					# (k * GRID_SQUARED + j) * 2
	add 	$t0, $a0, $t0				# &board[k][j];
	lhu 	$t1, 0($t0)					# $t1 = board[k][j];
	and     $t2, $s7, $t1				# $t2 = $t1 & value
	beq 	$t2, $0, finish_k_iter   	# board[k][j] & value = 0
	nor 	$t2, $s7, $0				# $t2 = ~value
	and 	$t1, $t1, $t2				# $t1 = board[k][j] & ~value
	sh 		$t1, 0($t0)					# board[k][j] &= ~value
	li 		$v0, 1						# chanegd = true;
finish_k_iter:
	add 	$s2, $s2, 1					# k++
	j 		second_inner_loop			# go to eliminate_square;


end:
	lw 		$ra, 0($sp)					# restore $ra
	add 	$sp, $sp, 12				# restore stack
    jr      $ra                         # return changed

###########################################################################
#                       rule 1 helper functions                           #
###########################################################################

get_square_begin:
	# round down to the nearest multiple of 4
	div	$v0, $a0, 4
	mul	$v0, $v0, 4
	jr	$ra


# UNTIL THE SOLUTIONS ARE RELEASED, YOU SHOULD COPY OVER YOUR VERSION FROM LAB 7
# (feel free to copy over the solution afterwards)
.globl has_single_bit_set
has_single_bit_set:
	beq	$a0, 0, hsbs_ret_zero	# return 0 if value == 0
	sub	$a1, $a0, 1
	and	$a1, $a0, $a1
	bne	$a1, 0, hsbs_ret_zero	# return 0 if (value & (value - 1)) == 0
	li	$v0, 1
	jr	$ra
hsbs_ret_zero:
	li	$v0, 0
	jr	$ra


# UNTIL THE SOLUTIONS ARE RELEASED, YOU SHOULD COPY OVER YOUR VERSION FROM LAB 7
# (feel free to copy over the solution afterwards)
get_lowest_set_bit:
	li	$v0, 0			# i
	li	$t1, 1

glsb_loop:
	sll	$t2, $t1, $v0		# (1 << i)
	and	$t2, $t2, $a0		# (value & (1 << i))
	bne	$t2, $0, glsb_done
	add	$v0, $v0, 1
	blt	$v0, 16, glsb_loop	# repeat if (i < 16)

	li	$v0, 0			# return 0
glsb_done:
jr $ra

###########################################################################
#                       rule 2                                            #
###########################################################################
# bool
# rule2(unsigned short board[GRID_SQUARED][GRID_SQUARED]) {
#   bool changed = false;
#   for (int i = 0 ; i < GRID_SQUARED ; ++ i) {
#     for (int j = 0 ; j < GRID_SQUARED ; ++ j) {
#       unsigned value = board[i][j];
#       if (has_single_bit_set(value)) {
#         continue;
#       }
#
#       int jsum = 0, isum = 0;
#       for (int k = 0 ; k < GRID_SQUARED ; ++ k) {
#         if (k != j) {
#           jsum |= board[i][k];        // summarize row
#         }
#         if (k != i) {
#           isum |= board[k][j];         // summarize column
#         }
#       }
#       if (ALL_VALUES != jsum) {
#         board[i][j] = ALL_VALUES & ~jsum;
#         changed = true;
#         continue;
#       } else if (ALL_VALUES != isum) {
#         board[i][j] = ALL_VALUES & ~isum;
#         changed = true;
#         continue;
#       }
#
#       // eliminate from square
#       int ii = get_square_begin(i);
#       int jj = get_square_begin(j);
#       unsigned sum = 0;
#       for (int k = ii ; k < ii + GRIDSIZE ; ++ k) {
#         for (int l = jj ; l < jj + GRIDSIZE ; ++ l) {
#           if ((k == i) && (l == j)) {
#             continue;
#           }
#           sum |= board[k][l];
#         }
#       }
#
#       if (ALL_VALUES != sum) {
#         board[i][j] = ALL_VALUES & ~sum;
#         changed = true;
#       }
#     }
#   }
#   return changed;
# }

rule2:
	sub	$sp, $sp, 48
	sw	$s0, 0($sp)
	sw	$s1, 4($sp)
	sw	$s2, 8($sp)
	sw	$s3, 12($sp)
	sw	$s4, 16($sp)
	sw	$s5, 20($sp)
	sw	$s6, 24($sp)
	sw	$s7, 28($sp)
	li	$s0, 0									# Changed == False
	li	$s1, 0									# iter i
outter_loop2:
	beq	$s1, 16, return							# i >= 16, return
	li	$s2, 0									# j = 0
inner_loop:
	beq	$s2, 16, increment_i					# j == 16

#       unsigned value = board[i][j];
#       if (has_single_bit_set(value)) {
#         continue;
#       }

	mul	$s6, $s1, 16							# the starting index of row i
	sll	$s6, $s6, 1 							# the starting location of row i
	sll	$s7, $s2, 1								# offset of col j
	add	$s7, $s7, $s6							# the location of board[i][j], we may want to reuse $s7
	add	$s7, $s7, $a0
	lhu	$s3, 0($s7)								# value = board[i][j]

#start check if
	sw	$a0, 32($sp)							# save a0
	sw	$ra, 36($sp)							# save ra
	move	$a0, $s3
	jal	has_single_bit_set						# call has a single bit
	lw	$a0, 32($sp)
	lw	$ra, 36($sp)
	beq	$v0, 1, increment_j						# take if <=> has single bit value == 1

#finish check if
#	int jsum = 0, isum = 0;
#       for (int k = 0 ; k < GRID_SQUARED ; ++ k) {
#         if (k != j) {
#           jsum |= board[i][k];        // summarize row
#         }
#         if (k != i) {
#           isum |= board[k][j];         // summarize column
#         }
#       }

	li	$s3, 0									# s3 = jsum = 0
	li	$s4, 0									# s4 = isum = 0
	li	$s5, 0									# s5 = k = 0
loop_k1:
	beq	$s5, 16, continue2						# k>=16, then skip the loop
if_k_j:
	beq	$s5, $s2, if_k_i						# if k==j, check next if
	sll	$t0, $s5, 1
	move	$s6, $s1
	mul	$s6, $s6, 16
	sll	$s6, $s6,1							# offset of k

	add	$s6, $s6, $t0							# location of board[i][k]
	add	$s6, $s6, $a0	
	lhu	$t0, 0($s6)								# board[i][k]
	or	$s3, $s3, $t0							# jsum = jsum|board[i][k]
if_k_i:
	beq	$s5, $s1, increment_k1					# if k==i, go to next iteration
	mul	$t0, $s5, 16							# the start index of row k
	sll	$t0, $t0, 2								# the start location of row k
	sll	$s6, $s2, 2								# the offset of col j
	add	$s6, $s6, $t0							# the location of board[k][j]
	add	$s6, $s6, $a0
	lhu	$t0, 0($s6)								# board[k][j]
	or	$s4, $s4, $t0							# isum = isum|board[k][j]
increment_k1:
	add	$s5, $s5, 1								# k++
	j	loop_k1

#       if (ALL_VALUES != jsum) {
#         board[i][j] = ALL_VALUES & ~jsum;
#         changed = true;
#         continue;
#       } else if (ALL_VALUES != isum) {
#         board[i][j] = ALL_VALUES & ~isum;
#         changed = true;
#         continue;
#       }
continue2:
	beq	 $s3,ALL_VALUES, else_if
	not	$s5, $s3								# ~jsum
	and	$s5, $s5, ALL_VALUES					# ALL_VALUES & ~jsum
	sh	$s5, 0($s7)								# board[i][j] = ALL_VALUES & ~jsum
	li	$s0, 1									# changed = 1
	j	increment_j

else_if:
	beq	$s4,ALL_VALUES, continue_next			# check ALL_VALUES, jsum
	not	$s5, $s4								# ~jsum
	and	$s5, $s5, ALL_VALUES					# ALL_VALUES & ~jsum
	sh	$s5, 0($s7)								# board[i][j] = ALL_VALUES & ~jsum
	li	$s0, 1									# changed = 1
	j	increment_j
continue_next:
#       int ii = get_square_begin(i);
#       int jj = get_square_begin(j);
#       unsigned sum = 0;
#       for (int k = ii ; k < ii + GRIDSIZE ; ++ k) {
#         for (int l = jj ; l < jj + GRIDSIZE ; ++ l) {
#           if ((k == i) && (l == j)) {
#             continue;
#           }
#           sum |= board[k][l];
#         }
#       }
#

	sw	$a0, 32($sp)
	sw	$ra, 36($sp)
	move	$a0, $s1							# a0 = i
	jal	get_square_begin 						# get_square_begin(i)
	move	$s3, $v0							# s3 = ii
	move	$a0, $s2
	jal	get_square_begin
	lw	$a0, 32($sp)
	lw	$ra, 36($sp)
	move	$s4, $v0							# s4 = jj
	li	$t0, 0									# sum = 0
	move	$t1, $s3							# t1 = k = ii
	add	$t6, $s3, 4								# ii+GRIDSIZE
	add	$t7, $s4, 4								# jj+GRIDSIZE
loop_inner_out:
	beq	$t1, $t6, continue_final 				# k >= ii+GRIDSIZE
	move	$t2, $s4	 						# t2 = l = jj
loop_innermost:
	beq	$t2, $t7, increment_k					# l >= jj+GRIDSIZE
	sub	$t3, $t1, $s1							# k-i
	sub	$t4, $t2, $s2							# l-j
	or	$t3, $t3, $t4							# k-i==0 abd l-j==0
	beq	$t3, 0, increment_l 					#continue

	move	$t3, $t1
	mul	$t3, $t3, 16							#the starting position of row k
	sll	$t3, $t3, 1								#the offset of row k
	sll	$t4, $t2, 1								#the offset of col l
	add	$t3, $t3, $t4							#the postion of board[k][l]
	add	$t3, $a0, $t3
	lhu	$t3, 0($t3)								#t3 = board[k][l]
	or	$t0, $t0, $t3							#sum = sum|board[k][l]


increment_l:
	add	$t2, $t2, 1
	j	loop_innermost

increment_k:
	add	$t1, $t1, 1
	j	loop_inner_out
#       if (ALL_VALUES != sum) {
#         board[i][j] = ALL_VALUES & ~sum;
#         changed = true;
#       }
continue_final:
	beq	$t0,ALL_VALUES, increment_j
	not	$t0, $t0
	and	$t0, $t0, ALL_VALUES
	sh	$t0, 0($s7)
	li	$s0, 1

increment_j:
	add	$s2, $s2, 1								#j++
	j	inner_loop
increment_i:
	add	$s1, $s1, 1								#i++
	j	outter_loop2
return:
	move	$v0, $s0

	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$s5, 20($sp)
	lw	$s6, 24($sp)
	lw	$s7, 28($sp)
	add	$sp, $sp, 48
	jr	$ra

###########################################################################
#                       my own solve                                      #
###########################################################################
# this function is used to solve the puzzle in a quick manner. I combine the
# rule 1 and rule 2 to make it run pretty fast.
puzzle_solver:



###########################################################################
#                       main function begins                              #
###########################################################################

#==========================================================================#
#       free registers: $t6 $t0
#==========================================================================#

main:
        li         $t6, BONK_INT_MASK                       # set up bit mask for bonk
        or         $t6, $t6, TIMER_INT_MASK                 # set up bit mask for timer
        or         $t6, $t6, REQUEST_PUZZLE_INT_MASK        # set up bit mask for request_puzzle
        or         $t6, $t6, 1                              # set up interrupt enable
        mtc0       $t6, $12                                 # set up the status register
        li         $t0, 10                                  # t0 = velocity of the spimBot
        sw         $t0, VELOCITY($0)                        # set the velocity of the spimBot
        li         $t2, 1                                   # set initial has right wall
        li         $t7, 0                                   # timer interrupt checker = 0;
        lw         $t6, TIMER($0)                           # get current time
        add        $t6, $t6, 10000                          # request 10000 cycle interrupt
        sw         $t6, TIMER($0)                           # request interrupt
        li         $t5, 0                                   # the checker of whether puzzle is ready
        la         $t4, puzzle                              # load the address of the puzzle we need to store into
        li         $t3, 1                                  # the counter, we need to solve at least 10 puzzle

get_20_keys_loop_request_puzzle:
        sw         $t4, REQUEST_PUZZLE($0)                  # store puzzle to the memory IO to request puzzle
        ble        $t3, $0, explore_loop                    # get 20 keys

get_20_keys_loop:
        beq        $t5, $0, get_20_keys_loop                # the puzzle is not ready yet
        sub        $sp, $sp, 56                             # allocate memory
        sw         $ra, 0($sp)
        sw         $a0, 4($sp)
        sw         $v0, 8($sp)
        sw         $s0, 12($sp)
        sw         $s1, 16($sp)
        sw         $s2, 20($sp)                             # all of those are fucking unsolved registers from rule 1
        sw         $s3, 24($sp)
        sw         $s4, 28($sp)
        sw         $s5, 32($sp)
        sw         $s6, 36($sp)
        sw         $s7, 40($sp)
        sw         $t0, 44($sp)
        sw         $t1, 48($sp)
        sw         $t2, 52($sp)
        move       $a0, $t4
        jal        solved
        lw         $ra, 0($sp)
        lw         $a0, 4($sp)
        lw         $v0, 8($sp)
        lw         $s0, 12($sp)
        lw         $s1, 16($sp)
        lw         $s2, 20($sp)                             # restore all of those are fucking unsolved registers from rule 1
        lw         $s3, 24($sp)
        lw         $s4, 28($sp)
        lw         $s5, 32($sp)
        lw         $s6, 36($sp)
        lw         $s7, 40($sp)
        lw         $t0, 44($sp)
        lw         $t1, 48($sp)
        lw         $t2, 52($sp)
        add        $sp, $sp, 56                             # delocate memory
        # sub        $sp, $sp, 56                             # allocate memory
        # sw         $ra, 0($sp)
        # sw         $a0, 4($sp)
        # sw         $v0, 8($sp)
        # sw         $s0, 12($sp)
        # sw         $s1, 16($sp)
        # sw         $s2, 20($sp)                             # all of those are fucking unsolved registers from rule 1
        # sw         $s3, 24($sp)
        # sw         $s4, 28($sp)
        # sw         $s5, 32($sp)
        # sw         $s6, 36($sp)
        # sw         $s7, 40($sp)
        # sw         $t0, 44($sp)
        # sw         $t1, 48($sp)
        # sw         $t2, 52($sp)
        # move       $a0, $t4
        # jal        rule1
        # lw         $ra, 0($sp)
        # lw         $a0, 4($sp)
        # lw         $v0, 8($sp)
        # lw         $s0, 12($sp)
        # lw         $s1, 16($sp)
        # lw         $s2, 20($sp)                             # restore all of those are fucking unsolved registers from rule 1
        # lw         $s3, 24($sp)
        # lw         $s4, 28($sp)
        # lw         $s5, 32($sp)
        # lw         $s6, 36($sp)
        # lw         $s7, 40($sp)
        # lw         $t0, 44($sp)
        # lw         $t1, 48($sp)
        # lw         $t2, 52($sp)
        # add        $sp, $sp, 56                             # delocate memory
        # sub        $sp, $sp, 56                             # allocate memory
        # sw         $ra, 0($sp)
        # sw         $a0, 4($sp)
        # sw         $v0, 8($sp)
        # sw         $s0, 12($sp)
        # sw         $s1, 16($sp)
        # sw         $s2, 20($sp)                             # all of those are fucking unsolved registers from rule 1
        # sw         $s3, 24($sp)
        # sw         $s4, 28($sp)
        # sw         $s5, 32($sp)
        # sw         $s6, 36($sp)
        # sw         $s7, 40($sp)
        # sw         $t0, 44($sp)
        # sw         $t1, 48($sp)
        # sw         $t2, 52($sp)
        # move       $a0, $t4
        # jal        rule1
        # lw         $ra, 0($sp)
        # lw         $a0, 4($sp)
        # lw         $v0, 8($sp)
        # lw         $s0, 12($sp)
        # lw         $s1, 16($sp)
        # lw         $s2, 20($sp)                             # restore all of those are fucking unsolved registers from rule 1
        # lw         $s3, 24($sp)
        # lw         $s4, 28($sp)
        # lw         $s5, 32($sp)
        # lw         $s6, 36($sp)
        # lw         $s7, 40($sp)
        # lw         $t0, 44($sp)
        # lw         $t1, 48($sp)
        # lw         $t2, 52($sp)
        # add        $sp, $sp, 56                             # delocate memory
        la         $t6, puzzle                               # load solution address
        sw         $t6, SUBMIT_SOLUTION                      # SUBMIT_SOLUTION
        li         $t5, 0                                   # set back checker and request another puzzle
        sub        $t3, $t3, 1                              # counter--
        j          get_20_keys_loop_request_puzzle

explore_loop:
        lw         $t1, RIGHT_WALL_SENSOR($0)               # t1 = right_wall_sensor

        bne        $t7, 1, continue                         # we still in the same block
        li         $t0, 0                                   # t0 = velocity of the spimBot
        sw         $t0, VELOCITY($0)                        # set the velocity of the spimBot
        li         $t7, 0
        sub        $sp, $sp, 4                              # allocate memory
        sw         $ra, 0($sp)                              # store ra
        lw         $t3, BOT_X($0)                           # t3 = BOT_X
        lw         $t4, BOT_Y($0)                           # t4 = BOT_Y
        div        $t3, $t3, 10                             # t3 /= t3
        mflo       $a0                                      # t3 = row number
        div        $t4, $t4, 10                             # t4 /= t4
        mflo       $a1                                      # t4 = row number
        jal        find_has_treasure
        li         $t0, 10                                  # t0 = velocity of the spimBot
        sw         $t0, VELOCITY($0)                        # set the velocity of the spimBot
        lw         $ra, 0($sp)                              # restore ra
        add        $sp, $sp, 4                              # dellocate memory
        lw         $t6, TIMER($0)                           # get current time
        add        $t6, $t6, 10000                          # request 10000 cycle interrupt
        sw         $t6, TIMER($0)                           # request interrupt
continue:
        not        $t3, $t1                                 # ~right_wall_sensor
        and        $t3, $t2, $t3                            # ~right_wall_sensor & t2
        beq        $t3, $0, skip_explore                           # no wall
turn_right:
        li         $t5, 90                                  # turn angle
        sw         $t5, ANGLE($0)
        sw         $0, ANGLE_CONTROL($0)                    # relatively turn 90
        lw         $t2, RIGHT_WALL_SENSOR($0)               # t2 = right_wall_sensor
        j          explore_loop
skip_explore:
        move       $t2, $t1                                 # store current hasWall
        j          explore_loop

        jr         $ra                                      # ret (useless)



###########################################################################
#                   kernal begin    try not put code here                 #
###########################################################################
.kdata
chunkIH:    .space 28
non_intrpt_str:    .asciiz "Non-interrupt exception\n"
unhandled_str:    .asciiz "Unhandled interrupt type\n"
.ktext 0x80000180
interrupt_handler:
.set noat
        move       $k1, $at                     # Save $at
.set at
        la         $k0, chunkIH
        sw         $a0, 0($k0)                  # Get some free registers
        sw         $v0, 4($k0)                  # by storing them to a global variable
        sw         $t0, 8($k0)
        sw         $t1, 12($k0)
        sw         $t2, 16($k0)
        sw         $t3, 20($k0)

        mfc0       $k0, $13                     # Get Cause register
        srl        $a0, $k0, 2
        and        $a0, $a0, 0xf                # ExcCode field
        bne        $a0, 0, non_intrpt



interrupt_dispatch:                             # Interrupt:
        mfc0       $k0, $13                     # Get Cause register, again
        beq        $k0, 0, done                 # handled all outstanding interrupts

        and        $a0, $k0, BONK_INT_MASK      # is there a bonk interrupt?
        bne        $a0, 0, bonk_interrupt

        and        $a0, $k0, TIMER_INT_MASK     # is there a timer interrupt?
        bne        $a0, 0, timer_interrupt

        and 	   $a0, $k0, REQUEST_PUZZLE_INT_MASK
        bne 	   $a0, 0, request_puzzle_interrupt

        li         $v0, PRINT_STRING            # Unhandled interrupt types
        la         $a0, unhandled_str
        syscall
        j    done

bonk_interrupt:
        sw      $v0, BONK_ACK                   # acknowledge interrupt
        li      $t0, 180                        # set turn around 180
        sw      $t0, ANGLE($0)                  # set the angle
        sw      $zero, ANGLE_CONTROL($0)        # set it relative
        li      $t0, 10                         # t0 = velocity of the spimBot
        sw      $t0, VELOCITY($0)               # set the velocity of the spimBot
        j       interrupt_dispatch              # see if other interrupts are waiting

request_puzzle_interrupt:
    	sw	    $v0, REQUEST_PUZZLE_ACK 	    #acknowledge interrupt
        li      $t5, 1
    	j	    interrupt_dispatch	            # see if other interrupts are waiting

timer_interrupt:
        sw      $v0, TIMER_ACK                  # acknowledge interrupt
        li      $t7, 1                          # set the checker
        j       interrupt_dispatch              # see if other interrupts are waiting

non_intrpt:                                     # was some non-interrupt
        li      $v0, PRINT_STRING
        la      $a0, non_intrpt_str
        syscall                                 # print out an error message
        # fall through to done

done:
        la      $k0, chunkIH
        lw      $a0, 0($k0)                     # Restore saved registers
        lw      $v0, 4($k0)
        lw      $t0, 8($k0)
        lw      $t1, 12($k0)
        lw      $t2, 16($k0)
        lw      $t3, 20($k0)
.set noat
        move    $at, $k1                        # Restore $at
.set at
        eret


