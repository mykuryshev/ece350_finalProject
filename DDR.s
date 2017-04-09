#JUST GENERAL IDEA AND RAMBLNGS SO FAR, LIKELY TO HAVE SYNTAX ERRORS AS I HAVEN'T FORMALLY CODED MIPS IN A WHILE
#Current version requires beq for our processor
#many registers used as constants or counters, maybe change

#how to retain memory location before a branch, just need to think through later
#how to handle multiple key inputs properly?
#sound
#blockmotion, getting there
#block register positions, getting there, in memory

.text 
main:

#register key, feel free to change or suggest storing something in memory, etc.
# $1 => 1, used to compare value to 1 for hit, present arrow
# $2 => 2, used to compare value to 2 for misses, missing arrow
# $3 => score, used to hold game score
# $4 => left h/m, holds whether left input was a hit or miss on input, and if tapped
# $5 => up h/m, holds whether up input was a hit or miss on input, and if tapped
# $6 => right h/m, holds whether right input was a hit or miss on input, and if tapped
# $7 => down h/m, holds whether down input was a hit or miss on input, and if tapped
# roaming register value, a A/T register (I think)
# $9 register state holding memory location for the DDR arrow array
# $10 register state which goes down the stack to find individual arrow array values
# NEED TO CHANGE $4,5,6,7 value to 1 or 2 depending on hit or miss, in hardware likely???
# $26, counter for arrow node, rel. first
# $27, counter cycle time, set to 100 mil for few second cycle
# $28 counter value to determine when to run next cycle
# $29 =>24 (for now), equalling number of cells

# 4x6 grid, each value stored in stack up relative to $9 location, $10 current cell checked,
# Can easily expand to make a larger grid

#     __      __     __      __
#    | 1 |   | 2 |  | 3 |   | 4 |
#     __      __     __      __
#    | 5 |   | 6 |  | 7 |   | 8 |
#     __      __     __      __
#    | 9 |   |10 |  |11 |   |12 |
#     __      __     __      __
#    |13 |   |14 |  |15 |   |16 |
#     __      __     __      __
#    |17 |   |18 |  |19 |   |20 |
#     __      __     __      __
#    |21 |   |22 |  |23 |   |24 |    //$9 should store 25’s ‘state’ and work backwords to not overwrite

start:
add $1, $0, 1 # $1 fixed for hit==1
add $2, $0, 2 # $2 fixed for miss==2
add $3, $0, $0 #set $3, score to 0
add $8, $0, $0
add $9, $0, $0
add $27, $0, $0 #can just have user vary $27 to speed up or slow down
addi $27, 100000000 #100 mil for couple second cycles? Math tricky
add $28, $0, $0 #initialize counter to zero
add $29, $0, 24 #set numCells to 24, 4 columns, 6 rows
jal initializeboard
# jal initsound #NEED if we go down this path
# jal initUI #NEED
j wait

#NEED TO DETERMINE TIMING AND SUCH FOR IDLE’s AND WAIT’s
wait: #used while waiting for game selection
#jal checkStart #maybe on press enter or such, then branch to start
#jal checkOptions #NEED to determine the options and where they’re stored
j wait

initializeboard:
sw $2, -1($9) #NEED to store empty states (2’s) in all positions of the board in memory
addi $8, 1
beq $8, $29 #once all array spots filled, we are set
jr $31

#general in level structure, NEED to determine how to wait long enough for playability
inLevel:
add $28, $0, $0 #reset counter
jal genArrows #NEED to determine how we want to create arrows, to beat, etc.? 
jal moveArrows #NEED to figure out (beq $blockSpace, $1, set blockspace to $2, row below to $1 to empty and fill below)
#jal playSong #NEEd, when we implement song
jal checkMiss #NEED, when block reaches end without an input, check and set score down
jal genRemoveArrow #NEED to figure out (beq $botRowBlockSpace, $1, remove, need beq or workaround)
jal updateScore #NEED to determine where it’s overwritten/stored, whatnot
jal idle 
j inLevel

idle:
jal checkInputs
addi $28, 1 $counter up 1, 2ns pause
blt $27, $28, inLevel #whenever clock idle surpasses set timing, then next in game cycle
j idle

moveArrowsStart: #check each block state $1 for lit, $2 dark, first cycle, else moveRestArrows
add $26, $0, $0 #reset node shift counter
lw $10, -1($9) #get next cell state into reg10, 
beq $10, $1, moveDown #or bne $10, $2 as each cell should only have reg value of 1 or 2
add $10, $0, $2 #reset to empty state, 2
add $20, $0, $31, #hold inLevel location while shifting rest
jal moveRest
jr $20

moveDown:
sw $1, 4($10) #store high value into next row below, assuming 4 columns for now (will change to change dynamically later)
jr $31

moveRest: #similar code to before except going down array from current node
lw $10, -1($10) #moving to previous cell memory position (is it $10 then or will it remain same)
beq $10, $1, moveDown 
add $10, $0, $2
addi $26, 1 #node completed count +1
bne $26, $29, moveRest #must cycle through all cells before ending shifts
jr $31



#using $4,$5,$6,$7 for L,U,R,D keys, respectively, if tapped, check if to score up/down
# also, not sure to check against state of $0 or what
checkInputs:
bne $4, $0, leftcheck
bne $5, $0, upcheck
bne $6, $0, rightcheck
bne $7, $0, downcheck
jr $31 #CHECK whether each of these jr’s leads to the right spot


#FOR EACH ARROW CHECK, REALLY COMPARE BOT ROW CELLS TO HIT/MISS
leftcheck:
lw $10, -4($9)
bne $10, $1, scoreUp
bne $10, $2, scoreDown
add $4, $0, $0 #reset left input state
jr $31 #jr here to return to branch location? How to retain old memory address

upcheck:
lw $10, -3($9)
bne $10, $1, scoreUp
bne $10, $2, scoreDown
add $5, $0, $0
jr $31

rightcheck:
lw $10, -2($9)
bne $10, $1, scoreUp
bne $10, $2, scoreDown
add $6, $0, $0
jr $31

downcheck:
lw $10, -1($9)
bne $10, $1, scoreUp
bne $10, $2, scoreDown
add $7, $0, $0
jr $31

scoreUp:
addi $3, 100 #arbitrarily adding 100 to score for a hit
jr $31 

scoreDown: 
addi $3, -100 #arbitrarily subtracting 100 to score on miss (can also lose a life or such)
jr $31




# 6x4 grid for DDR, 
# Ask about non bloc image displays

