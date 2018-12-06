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
finish_request_puzzle:  .word 0
treasure_map:           .word 404
###########################################################################

.text
###########################################################################
#                     self-defined functions goes here                    #
###########################################################################

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

###########################################################################
#                       my own solve                                      #
###########################################################################
# this function is used to solve the puzzle in a quick manner. I combine the
# rule 1 and rule 2 to make it run pretty fast.
puzzle_solver:



###########################################################################
#                       main function begin                               #
###########################################################################
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
        mflo       $a1                                      # t3 = row number
        div        $t4, $t4, 10                             # t4 /= t4
        mflo       $a0                                      # t4 = row number
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
        beq        $t3, $0, skip                            # no wall
turn_right:
        li         $t5, 90                                  # turn angle
        sw         $t5, ANGLE($0)
        sw         $0, ANGLE_CONTROL($0)                    # relatively turn 90
        lw         $t2, RIGHT_WALL_SENSOR($0)               # t2 = right_wall_sensor
        j          explore_loop
skip:
        move       $t2, $t1                                 # store current hasWall
        j          explore_loop

        jr         $ra                                      # ret (useless)



###########################################################################
#                   kerner begin    try not put code here                 #
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
