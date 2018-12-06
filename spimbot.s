.data
# syscall constants
PRINT_STRING            = 4
PRINT_CHAR              = 11
PRINT_INT               = 1
NEW_LINE:               .asciiz "\n"
SPACE_LINE:             .asciiz "-"

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
treasure_map: .word 404
###########################################################################

###########################################################################
#                     self-defined functions goes here                    #
###########################################################################

# this function in C code: bool find_has_treasure(int x, int y);
# take in two parameters x and y, which are spimbot current location and return
# whether current location has treasure. 1 if has 0 if there is no treasure.
find_has_treasure:

# this function is used to solve the puzzle in a quick manner. I combine the
# rule 1 and rule 2 to make it run pretty fast.
puzzle_solver:


###########################################################################
#                       main function begin                               #
###########################################################################
.text
main:
    	# Insert code here
        li         $t6, BONK_INT_MASK                       # set up bit mask for bonk
        or         $t6, $t6, TIMER_INT_MASK                 # set up bit mask for timer
        or         $t6, $t6, REQUEST_PUZZLE_INT_MASK        # set up bit mask for request_puzzle
        or         $t6, $t6, 1                              # set up interrupt enable
        mtc0       $t6, $12                                 # set up the status register
        li         $t0, 10                                  # t0 = velocity of the spimBot
        sw         $t0, VELOCITY($0)                        # set the velocity of the spimBot
        li         $t0, 1                                   # set initial has right wall

explore_loop:
        lw         $t1, RIGHT_WALL_SENSOR($0)               # t1 = right_wall_sensor
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
