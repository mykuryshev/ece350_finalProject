.text
main:
addi $1,$0,0
addi $2,$0,65000 #####Processor cycles of Idle time
noop
noop
noop
noop
noop
sll  $2, $2, 2
noop
noop
noop
noop
noop
add $10,$0,$2 #Register has max cycles also
noop
noop
noop
noop
noop
sw   $2,0($1)
addi $2,$0,61000 #####Lower Boundary of Key PRess
noop
noop
noop
noop
noop
sw   $2,1($1)
addi $2,$0,65000 #####Upper Boundary of Key press
noop
noop
noop
noop
noop
sw   $2,2($1)
addi $2,$0,6000 #####LEFT ARROW START LOCATION
noop
noop
noop
noop
noop
sw   $2,3($1)
addi $2,$0,6100 #####RIGHT ARROW START LOCATION
noop
noop
noop
noop
noop
sw   $2,4($1)
addi $2,$0,6200 #####UP ARROW LOCATION
noop
noop
noop
noop
noop
sw   $2,5($1)
addi $2,$0,6300 #####DOWN ARROW LOCATION
noop
noop
noop
noop
noop
sw   $2,6($1)
addi $2,$0,1 #####Value of 1(Left Arrow condition)
noop
noop
noop
noop
noop
sw   $2,7($1)
addi $2,$0,2 #####Value of 2(Right Arrow condition)
noop
noop
noop
noop
noop
sw   $2,8($1)
addi $2,$0,3 #####Value of 3(Up Arrow condition)
noop
noop
noop
noop
noop
sw   $2,9($1)
addi $2,$0,4 #####Value of 4(Down Arrow Condition)
noop
noop
noop
noop
noop
sw   $2,10($1)
addi $5,$0,500
addi $6,$0,1 #Load first value as 1(hard coded sequence of arrows)
noop
noop
noop
noop
noop
sw   $6,0($5)
addi $6,$0,2 #Load second value as 2(hard coded sequence of arrows)
noop
noop
noop
noop
noop
sw   $6,1($5)
addi $6,$0,3 #Load value as 3(hard coded sequence of arrows)
noop
noop
noop
noop
noop
sw   $6,2($5)
addi $6,$0,4 #Load first value as 4(hard coded sequence of arrows)
noop
noop
noop
noop
noop
sw   $6,3($5)
addi $3,$0,100
addi $4,$0,0 #####SCORE
noop
noop
noop
noop
noop
sw   $4,0($3)
addi $3,$0,101
addi $4,$0,0 #####ARROW COUNT
noop
noop
noop
noop
noop
sw   $4,0($3)
addi $3,$0,102
addi $4,$0,0 #####MISS COUNT
noop
noop
noop
noop
noop
sw   $4,0($3)
addi $9,$0,0 # Initial Wait count
addi $17,$0,20 # Initial genarrow count
addi $18,$0,21 # Max genarrow count
addi $19,$0,499

addi $14, $0, 210
noop
addi $16, $0, 260
noop
storeDmem:
sw $0, 0($14)
sw $0, 1($14)
addi $14, $14, 10
noop
noop
noop
noop
noop
blt $14, $16, storeDmem
noop
noop
noop
noop
noop
addi $14, $0, 0
addi $16, $0, 0

inLevel:
addi $17,$17,1
noop
noop
noop
noop
noop
blt $17,$18,SkipgenArrows #If current count is less than the max than skip generate arrow 
noop
noop
noop
noop
noop
addi $17, $0, 0
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
noop
noop
noop
noop
noop
lw   $26,0($19) # Loads first memory spot into reg $26
addi $1,$0,0
noop
noop
noop
noop
noop
sw   $31,51($1) #Remember this is new
lw   $2,7($1) #Here we load the constant of 1 from memory to compare to random number
noop
noop
noop
noop
noop
bne  $2,$26, loadLeftStartPoint # We jump to code that defines a register with the left arrow start
noop
noop
noop
noop
noop
lw   $2,8($1) #Here we load the constant of 1 from memory to compare to random number
noop
noop
noop
noop
noop
bne  $2,$26, loadRightStartPoint
noop
noop
noop
noop
noop
lw   $2,9($1) #Here we load the constant of 1 from memory to compare to random number
noop
noop
noop
noop
noop
bne  $2,$26, loadUpStartPoint
noop
noop
noop
noop
noop
lw   $2,10($1) #Here we load the constant of 1 from memory to compare to random number
noop
noop
noop
noop
noop
bne  $2,$26, loadDownStartPoint #j end # Do we end game if there are no more arrows.
noop
noop
noop
noop
noop
j end
noop
noop
noop
noop
noop
loadLeftStartPoint: 
addi $1,$0,0
noop
noop
noop
noop
noop
lw   $2,3($1)
noop
noop
noop
noop
noop
sw   $2,601($1)
addi $14,$0,1 # Use the temp variable to load down arrow condition
noop
noop
noop
noop
noop
sw   $14,600($1) # store the arrow condition(i.e. color mapping)
noop
noop
noop
noop
noop
jal ArrowFree
noop
noop
noop
noop
noop
j  buildArrow
noop
noop
noop
noop
noop
loadRightStartPoint:
addi $1,$0,0
noop
noop
noop
noop
noop
lw   $2,4($1) # Initial ref index for right arrow
noop
noop
noop
noop
noop
sw   $2,601($1)
addi $14,$0,2 # Use the temp variable to load down arrow condition
noop
noop
noop
noop
noop
sw   $14,600($1) # store the arrow condition(i.e. color mapping)
noop
noop
noop
noop
noop
jal ArrowFree
noop
noop
noop
noop
noop
j    buildArrow
noop
noop
noop
noop
noop
loadUpStartPoint:
addi $1,$0,0
noop
noop
noop
noop
noop
lw   $2,5($1) #Initial ref index for Up arrow
noop
noop
noop
noop
noop
sw   $2,601($1)
addi $14,$0,3 # Use the temp variable to load down arrow condition
noop
noop
noop
noop
noop
sw   $14,600($1) # store the arrow condition(i.e. color mapping)
noop
noop
noop
noop
noop
jal ArrowFree
noop
noop
noop
noop
noop
j    buildArrow 
noop
noop
noop
noop
noop
loadDownStartPoint:
addi $1,$0,0
noop
noop
noop
noop
noop
lw   $2,6($1) # Initial ref index for Down Arrow
noop
noop
noop
noop
noop
sw   $2,601($1) # Store the ref index bein used for build arrow
addi $14,$0,4 # Use the temp variable to load down arrow condition
noop
noop
noop
noop
noop
sw   $14,600($1) # store the arrow condition(i.e. color mapping)
noop
noop
noop
noop
noop
jal ArrowFree
noop
noop
noop
noop
noop
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
noop
noop
noop
noop
noop
j StartBuildLoop
noop
noop
noop
noop
noop
StartBuildLoop:
addi $1,$0,600 # This memory location has the location of the start index of the object
noop
noop
noop
noop
noop
lw   $7,1($1)  # Loads into reg $7 the first the write location
addi $8, $0, 1 # lw   $8,0($1)  # Loads arrow type (color mapping) #IGNORE FOR NOW
noop
noop
noop
noop
noop
sw   $8,0($7)  # Drawn from color location
addi $7,$7,2
noop
noop
noop
noop
noop
sw   $7,1($1)
addi $12,$12,2
noop
noop
noop
noop
noop
blt $12,$27,StartBuildLoop
noop
noop
noop
noop
noop
addi $11,$11,1 # Michaels code
addi $7,$7,591
noop
noop
noop
noop
noop
sw $7, 1($1)
addi $12,$12,-49
noop
noop
noop
noop
noop
blt $11,$27,StartBuildLoop
noop
noop
noop
noop
noop
addi $5,$0,0
addi $3,$0,101
noop
noop
noop
noop
noop
lw   $14,0($3)
noop
noop
noop
noop
noop
addi $4,$14,1 #####Update arrow count
noop
noop
noop
noop
noop
sw   $4,0($3)
addi $14,$0,0
addi $1,$0,0
noop
noop
noop
noop
noop
lw $31,51($1)
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
wait:
addi $9,$9,1 #jal checkKeyInput
noop
noop
noop
noop
noop
blt $9,$10,wait
noop
noop
noop
noop
noop
addi $9,$0,0
noop
noop
noop
noop
noop
j inLevel
noop
noop
noop
noop
noop
ArrowFree:
addi $5,$0,200 # Loads the addresses for arrow slots
addi $16,$0,259 #Loads max arrow slot indicator
ArrowFreeLoop:
noop
noop
noop
noop
noop
addi $5,$5,10 #Increments arrow slot number
noop
noop
noop
noop
noop
lw   $14,0($5)# Loads value in arrow slot from memory
noop
noop
noop
noop
noop
bne  $14,$0,StoreArrow #If arrow type is equal to 0 then slot is free
noop
noop
noop
noop
noop
blt  $16,$5,jumpback #Check if max arrow slot is less than current address
noop
noop
noop
noop
noop
j ArrowFreeLoop # Jumps back in the loop
noop
noop
noop
noop
noop
StoreArrow: 
addi $1,$0,600 # Will be used to store just created arrow
noop
noop
noop
noop
noop
lw   $2,0($1) # Loads arrow type
noop
noop
noop
noop
noop
sw   $2,0($5) # Saves Arrow type
noop
noop
noop
noop
noop
lw   $2,1($1) # Loads Arrow Location
noop
noop
noop
noop
noop
sw   $2,1($5) # Saves Arrow Location
noop
noop
noop
noop
noop
jr $31 # Jumps back to genarrow module
noop
noop
noop
noop
noop

jumpback:
noop # this module is if no more slots are free
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

end:
addi $14,$0,12000
addi $16,$0,1
noop
noop
noop
noop
noop
sw   $16,0($14)
noop
noop
noop
noop
noop
j end
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
