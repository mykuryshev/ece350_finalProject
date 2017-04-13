#DDR.s is probably a wash, too many syntax errors, and thought up on the spot,
#probably better if we start our code off of this or another file

#IF THIS WORKS AND MEMORY INITIALIZED PROPERLY, THEN SHOULD OBSERVE 
#RIGHT ARROW APPEAR AT START, FOLLOWED BY SHORT IDLE TIME,
#AND THEN A LEFT ARROW SHOULD APPEAR AS WELL

#NOTHING SHOULD MOVE OR DISAPPEAR,
#INITIAL SCREEN LOADING UP TO THE PROCESSOR AS OF NOW

#GEN ARROW IS REALLY GEN ANY IMAGE AND REQUIRES 4 VALUE CHANGES, $9,$10,$14,$15
#TO PRODUCE AN IMAGE FROM A LOCATION OF ANY SIZE TO A LOCATION ON THE BOARD

#ASSUMING THIS ALL WORKS OF COURSE :) 


##################################################################
#register key, rewritten from DDR.s 
# $1 => constant holding number of processor cycles of idle time

# $6 => counts idle time during which can check inputs and such
# $7 => counts which cycle of arrow creation we are in, in genArrowCheck

# $8 => stores the rgb value written to a particular addr
# $9 => stores the currently loading images top-left addr
# $10 => stores the addr of where we will be writing pixels to
# $11 => counts the nth column in our loop written to (to $14 max)
# $12 => counts the nth row in our loop written to (to $15 max)

# $14 => stores the row width
# $15 => stores the column height (separate val. as we won't just draw arrows eventually)

# $16 => stores the left arrow image top-left addr
# $17 => stores the up arrow image top-left addr
# $18 => stores the right arrow image top-left addr
# $19 => stores the down arrow image top-left addr 

# $20 => stores whether to draw a left arrow or not
# $21 => stores whether to draw an up arrow or not 
# $22 => stores whether to draw a right arrow or not
# $23 => stores whether to draw an down arrow or not 

# $24 => stores where the left arrow will be drawn on the display
# $25 => stores up arrow draw location (25 pixel blank spacer rn)
# $26 => stores right arrow draw location 
# $27 => stores down arrow draw location
##################################################################


.text 
main:

start: #initialize register values
addi $1, $0, 10000000   # constant holding number of processor cycles of idle time

addi $6, $0, 0   #counts idle time during which can check inputs and such
addi $7, $0, 0   #counts which cycle of arrow creation we are in, in genArrowCheck

addi $8, $0, 0   #stores the rgb value written to a particular addr
addi $9, $0, 0   #stores the currently loading images top-left addr
addi $10, $0, 0  #stores the addr of where we will be writing pixels to
addi $11, $0, 0  #counts the nth column in our loop written to (to $14 max)
addi $12, $0, 0  #counts the nth row in our loop written to (to $15 max)

addi $14, $0, 50 #stores the row width
addi $15, $0, 50 #stores the column height (separate val. as we won't just draw arrows eventually)

addi $16, $0, 310000 #stores the left arrow image top-left addr
addi $17, $0, 320000 #stores the up arrow image top-left addr
addi $18, $0, 330000 #stores the right arrow image top-left addr
addi $19, $0, 340000 #stores the down arrow image top-left addr 

addi $20, $0, 0 #stores whether to draw a left arrow or not
addi $21, $0, 0 #stores whether to draw an up arrow or not 
addi $22, $0, 0 #stores whether to draw a right arrow or not
addi $23, $0, 0 #stores whether to draw an down arrow or not 

addi $24, $0, 350000 #stores where the left arrow will be drawn on the display
addi $25, $0, 350075 #stores up arrow draw location (25 pixel blank spacer rn)
addi $26, $0, 350150 #stores right arrow draw location 
addi $27, $0, 350225 #stores down arrow draw location

addi $29, $0, 0 #stores original pc location if double-jumping
j inLevel


inLevel:
jal arrowGenSelect #controls which arrows are generated
jal genArrowCheck
jal idleTime
j inLevel

#change the 1's to 0's or v-v to draw or not draw arrows or add a more complex function
#can only turn on one arrow at a time or else need more registers to loop properly
#also, multiple key inputs might be messy anyways
arrowGenSelect: 
addi $20, $0, 0 #left
addi $21, $0, 0 #up
addi $22, $0, 0 #right 
addi $23, $0, 1 #down
jr $31

#check each arrow condition if generating
genArrowCheck: 
addi $9, $16, 0  #store left arrow image location to $9
addi $10, $24, 0 #store where left-arrow drawn to $10
bne $20, $0, genArrow #or can have beq $20, $0, etc...
addi $9, $17, 0
addi $10, $25, 0
bne $21, $0, genArrow
addi $9, $18, 0
addi $10, $26, 0
bne $22, $0, genArrow
addi $9, $19, 0
addi $10, $27, 0
bne $23, $0, genArrow
j clearArrowGen #jump back to inLevel location if no arrows generated


#really could be gen image...
#just need to store the appropriate $9,$10,$14,$15 before starting
genArrow:
add $11, $0, $0 #reset pixel counter for row
add $12, $0, $0 #reset pixel counter for columns
j rowGenLoopStart 
rowGenLoopStart:
lw $8, 0($9) #load arrow's image first pixel rgb val
sw $8, 0($10) #store pixel rgb val to appropriate display address
addi $9, $9, 1
addi $11, $11, 1
blt $11, $14, rowGenLoopStart #to the next column if not at last column
add $11, $0, $0
addi $12, $12, 1
sub $9, $9, $14 #back to column 0
addi $9, $9, 640 #down 1 row, display always 640 pixels across for us
blt $12, $15, rowGenLoopStart #to the next row if not at last row
j clearArrowGen

#reset each arrow's turn on 'boolean' condition
clearArrowGen:
addi $20, $0, 0
addi $21, $0, 0
addi $22, $0, 0
addi $23, $0, 0
jr $31 #back to inLevel

#counter that counts enough times for a noticeable time to us
#this is when we would ideally check key inputs and as this is bulk of processor time
idleTime:
addi $6, $6, 1
blt $6, $1, idleTime
addi $20, $0, 1 #select left arrow to be turned on next cycle
jr $31 
