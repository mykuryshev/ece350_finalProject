.text
main:
addi $1,$0,0
addi $2,$0,6500 #####Processor cycles of Idle time
sll  $2, $2, 4
add $10,$0,$2 #Register has max cycles also
sw   $2,0($1)
addi $2,$0,6700 #####Lower Boundary of Key PRess
sw   $2,1($1)
addi $2,$0,8400 #####Upper Boundary of Key press
sw   $2,2($1)
addi $2,$0,100 #####LEFT ARROW START LOCATION
sw   $2,3($1)
addi $2,$0,300 #####RIGHT ARROW START LOCATION
sw   $2,4($1)
addi $2,$0,500 #####UP ARROW LOCATION
sw   $2,5($1)
addi $2,$0,700 #####DOWN ARROW LOCATION
sw   $2,6($1)
addi $2,$0,1 #####Value of 1(Left Arrow condition)
sw   $2,7($1)
addi $2,$0,2 #####Value of 2(Right Arrow condition)
sw   $2,8($1)
addi $2,$0,3 #####Value of 3(Up Arrow condition)
sw   $2,9($1)
addi $2,$0,4 #####Value of 4(Down Arrow Condition)
sw   $2,10($1)

addi $5,$0,500
addi $6,$0,1 #Load first value as 1(hard coded sequence of arrows)
sw   $6,0($5)
addi $6,$0,3 #Load second value as 1(hard coded sequence of arrows)
sw   $6,1($5)
addi $6,$0,1 #Load value as 1(hard coded sequence of arrows)
sw   $6,2($5)
addi $6,$0,4 #Load first value as 1(hard coded sequence of arrows)
sw   $6,3($5)
addi $6,$0,2 #Load first value as 1(hard coded sequence of arrows)
sw   $6,4($5)
addi $6,$0,3 #Load first value as 1(hard coded sequence of arrows)
sw   $6,5($5)
addi $6,$0,1 #Load first value as 1(hard coded sequence of arrows)
sw   $6,6($5)
addi $6,$0,4 #Load first value as 1(hard coded sequence of arrows)
sw   $6,7($5)
addi $6,$0,1 #Load first value as 1(hard coded sequence of arrows)
sw   $6,8($5)
addi $6,$0,2 #Load first value as 1(hard coded sequence of arrows)
sw   $6,9($5)

addi $3,$0,100
addi $4,$0,0 #####SCORE
sw   $4,0($3)
addi $3,$0,101
addi $4,$0,0 #####ARROW COUNT
sw   $4,0($3)
addi $3,$0,102
addi $4,$0,0 #####MISS COUNT
sw   $4,0($3)
addi $9,$0,0 # Initial Wait count
addi $17,$0,0 # Initial genarrow count
addi $18,$0,51 # Max genarrow count
addi $19,$0,500

inLevel:
addi $17,$17,1
blt $17,$18,SkipgenArrows #If current count is less than the max than skip generate arrow 
noop
noop
noop
noop
noop
jal genArrows #Create arrows
noop
noop
noop
noop
noop
SkipgenArrows:
jal moveArrows #Move the arrows
noop
noop
noop
noop
noop
jal RefreshArrows #Might not be necessary
noop
noop
noop
noop
noop
jal wait #Hold
noop
noop
noop
noop
noop
j inLevel # Jump Back / Might not be necessary cause of j inLEvel in wait
noop
noop
noop
noop
noop

genArrows:

addi $19,$19,1 # MAKE CONDITION FOR WHEN THEY'RE PAST 510.

lw   $26,0($19) # Loads first memory spot into reg $26

addi $1,$0,0
lw   $2,7($1) #Here we load the constant of 1 from memory to compare to random number
bne  $2,$26, loadLeftStartPoint # We jump to code that defines a register with the left arrow start
noop
noop
noop
noop
noop
lw   $2,8($1) #Here we load the constant of 1 from memory to compare to random number
bne  $2,$26, loadRightStartPoint
noop
noop
noop
noop
noop
lw   $2,9($1) #Here we load the constant of 1 from memory to compare to random number
bne  $2,$26, loadUpStartPoint
noop
noop
noop
noop
noop
lw   $2,10($1) #Here we load the constant of 1 from memory to compare to random number
bne  $2,$26, loadDownStartPoint #j end # Do we end game if there are no more arrows.
noop
noop
noop
noop
noop

loadLeftStartPoint: 
addi $1,$0,0
lw   $2,3($1)
sw   $2,601($1)
addi $14,$0,1 # Use the temp variable to load down arrow condition
sw   $14,600($1) # store the arrow condition(i.e. color mapping)
j    buildArrow
noop
noop
noop
noop
noop
loadRightStartPoint:
addi $1,$0,0
lw   $2,4($1) # Initial ref index for right arrow
sw   $2,601($1)
addi $14,$0,2 # Use the temp variable to load down arrow condition
sw   $14,600($1) # store the arrow condition(i.e. color mapping)
j    buildArrow
noop
noop
noop
noop
noop
loadUpStartPoint:
addi $1,$0,0
lw   $2,5($1) #Initial ref index for Up arrow
sw   $2,601($1)
addi $14,$0,3 # Use the temp variable to load down arrow condition
sw   $14,600($1) # store the arrow condition(i.e. color mapping)
j    buildArrow 
noop
noop
noop
noop
noop
loadDownStartPoint:
addi $1,$0,0
lw   $2,6($1) # Initial ref index for Down Arrow
sw   $2,601($1) # Store the ref index bein used for build arrow
addi $14,$0,4 # Use the temp variable to load down arrow condition
sw   $14,600($1) # store the arrow condition(i.e. color mapping)
j buildArrow
noop
noop
noop
noop
noop
buildArrow: 
addi $11,$0,0 #Reset row counter
addi $12,$0,0 #Reset column counter
addi $27,$0,50 # Max value for column
j StartBuildLoop
noop
noop
noop
noop
noop
StartBuildLoop:
addi $1,$0,600 # This memory location has the location of the start index of the object
lw   $7,1($1)  # Loads into reg $7 the first the write location
lw   $8,0($1)  # Loads arrow type (color mapping) 
sw   $8,0($7)  # Drawn from color location
addi $7,$7,2
addi $12,$12,2

blt $12,$27,StartBuildLoop
noop
noop
noop
noop
noop
addi $11,$11,1 # Michaels code
addi $7,$7,591
addi $12,$12,-49

blt $11,$27,StartBuildLoop
noop
noop
noop
noop
noop
addi $3,$0,101
lw   $14,0($3)
addi $4,$14,1 #####Update arrow count
sw   $4,0($3)
addi $14,$0,0


jr $31
noop
noop
noop
noop
noop

moveArrows:
addi $5,$0,210 #Loads first arrow mem location
addi $16,$0,4000 # Limit for off the screen
moveArrowLoop:
lw   $6,0($5) #Loads the arrow type
bne  $6,$0,nextArrow #If the arrow type code is 0, then there is no arrow and we move on
noop
noop
noop
noop
noop
lw   $6,1($5) #Loads Arrow Location
addi $14,$6,1280 # Adds arrow location to move down 2 rows
blt  $16,$14,RemoveArrow  #handling for arrows that "go off the screen",so limit is less than location 
noop
noop
noop
noop
noop
ContinueMoving: 
sw   $14,1($5) #Saves new arrow location to memory
addi $14,$0,0 # Reset temp variable
nextArrow:
addi $5,$5,10
addi $14,$0,259 #emp variable Loaded with a number that if $5 exceeds we go back to inlevel
blt  $5,$14,moveArrowLoop #If value of $5 is less than 259 loop again
noop
noop
noop
noop
noop
jr $31
noop
noop
noop
noop
noop

RemoveArrow:
sw $0,1($5) #Deletes data for arrow location
sw $0,0($5) # Deletes data for arrow type
addi $14,$0,0 # Resets temp variable
j nextArrow
noop
noop
noop
noop
noop

RefreshArrows:
addi $5,$0,210 #Loads first arrow type address
addi $1,$0,600
sw   $31,50($1) # HOlds the OG jal address
RefreshArrowLoop:
lw   $6,0($5) #Loads the arrow type
sw   $6,0($1) # Stores that value into mem spot that build arrow uses
lw   $6,1($5) #Loads arrow location
sw   $6,1($1) #Stores the location into mem spot that builds arrow
jal buildArrow
noop
noop
noop
noop
noop
addi $5,$5,10 # Goes to the next arrow
addi $14,$0,259 #temp variable Loaded with a number that if $5 exceeds we go back to inlevel
blt  $5,$14,RefreshArrowLoop #Checks if all the arrows are checked
noop
noop
noop
noop
noop
lw $31,50($1)
jr $31 #If all the arrows are checked
noop
noop
noop
noop
noop


wait:
addi $9,$9,1 #jal checkKeyInput
blt $9,$10,wait
noop
noop
noop
noop
noop
addi $9,$0,0
j inLevel
noop
noop
noop
noop
noop

.data
wow: .word 0x0000B504
mystring: .string ASDASDASDASDASDASD
var: .char Z
label: .char A
heapsize: .word 0x00000000
myheap: .word 0x00000000
