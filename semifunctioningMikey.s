.text
main: 
addi $1, $0, 1 #This is block drawing
addi $5, $0, 0
addi $4, $0, 50
addi $6, $0, 0
addi $10, $0, 65000 #65000 sll $10, $10, 2 #around 1 million now
addi $9, $9, 0
addi $29,$0,1

initArrowListInMem:
addi $25, $0, 10 #initial cycle to appear
addi $26, $0, 1 #arrow type
addi $27, $0, 38000 #arrow bot location, not really needed but had it here
sw $25, 400($0)
sw $26, 401($0)
sw $27, 402($0)
addi $25, $0, 30
addi $26, $0, 3
addi $27, $0, 38200
sw $25, 403($0)
sw $26, 404($0)
sw $27, 405($0)
addi $25, $0, 40
addi $26, $0, 2
addi $27, $0, 38100
sw $25, 406($0)
sw $26, 407($0)
sw $27, 408($0)
addi $25, $0, 100
addi $26, $0, 4
addi $27, $0, 38300
sw $25, 409($0)
sw $26, 410($0)
sw $27, 411($0)
addi $25, $0, 110
addi $26, $0, 1
addi $27, $0, 38000
sw $25, 412($0)
sw $26, 413($0)
sw $27, 414($0)
addi $25, $0, 140
addi $26, $0, 2
addi $27, $0, 38100
sw $25, 415($0)
sw $26, 416($0)
sw $27, 417($0)
addi $25, $0, 165
addi $26, $0, 3
addi $27, $0, 38200
sw $25, 418($0)
sw $26, 419($0)
sw $27, 420($0)
addi $25, $0, 180
addi $26, $0, 1
addi $27, $0, 38000
sw $25, 421($0)
sw $26, 422($0)
sw $27, 423($0)
addi $25, $0, 205
addi $26, $0, 4
addi $27, $0, 38300
sw $25, 424($0)
sw $26, 425($0)
sw $27, 426($0)
addi $25, $0, 230
addi $26, $0, 2
addi $27, $0, 38100
sw $25, 427($0)
sw $26, 428($0)
sw $27, 429($0)
addi $25, $0, 0
addi $26, $0, 0
addi $27, $0, 0

addi $28, $0, 0 #will store scan code for valid key inputs #key codes stored in memory 800-899, 800 left, 801 up, 802 right, 803 down
addi $16, $0, 107 #left
sw $16, 800($0)
addi $16, $0, 117 #up
sw $16, 801($0)
addi $16, $0, 116 #right
sw $16, 802($0)
addi $16, $0, 114 #down
sw $16, 803($0)
addi $16, $0, 0
addi $16, $0, 0 
sw $16, 900($0) #store score


beginning:


inLevel:
jal genArrows
noop
noop
noop
noop
noop
addi $1, $0, 1 #not really needed
addi $15, $0, 1 #to draw
jal sweepDraw #Draw real stuff
noop
noop
noop
noop
noop
addi $2, $0, 5800 # $2 is starting point for random block
jal stall #Chill
noop
noop
noop
noop 
noop
bne $28, $0, skipstep 
noop
noop
noop
noop 
noop
jal checkInputsInLevel
noop
noop
noop
noop 
noop
skipstep:
noop
noop
noop
noop 
noop
addi $15, $0, 0
noop
noop
noop
noop 
noop
jal sweepDraw #Erase
noop
noop
noop
noop
noop
jal moveArrows
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



genArrows:
addi $20, $0, 400
addi $24, $0, 435 #max stored arrow for gen in memory addr.


sweep3:
blt $24, $20, finishGen #if past gen list
noop
noop
noop
noop
noop
lw $21, 0($20) #cycle count necessary to load
lw $22, 1($20) #arrow type, if present
lw $23, 2($20) #arrow bottom location, again, if present
bne $22, $0, nextArrowGen #if no arrow here, will want next one
noop
noop
noop
noop
noop
blt $6, $21, nextArrowGen #if cycle count not at time to gen, then skip for now
noop #if we get here, then we are creating a new arrow
noop
noop
noop
noop
addi $18, $0, 198 #reset so to not leave empty memory places
addi $19, $0, 300


placeArrowInMemLoop:
addi $18, $18, 3 
lw $25, 1($18)
bne $25, $0, placeArrow #might want to add a limiter just in case later but all good for now hopefully
noop
noop
noop
noop
noop
j placeArrowInMemLoop #may want to insert out of bounds branch before this... 
noop
noop
noop
noop
noop


placeArrow:
sw $0, 0($18)
sw $22, 1($18) #place arrow type in active mem
sw $23, 2($18) #place arrow loc in active mem
sw $0, 0($20) #remove arrow in pregen list
sw $0, 1($20) #remove arrow in pregen list
sw $0, 2($20) #remove arrow in pregen list


finishGen:
addi $21,$0,0
addi $22,$0,0
addi $23,$0,0
jr $31 #if last arrow checked was gen'd
noop
noop
noop
noop
noop



nextArrowGen:
addi $20, $20, 3
j sweep3
noop
noop
noop
noop
noop



testDraw:
addi $5, $0, 0
addi $1, $17, 0
addi $3, $0, 37800
addi $2, $3, -32000
j drawLoop
noop
noop
noop
noop
noop



draw: 
addi $5, $0, 0
addi $2, $3, -32000
addi $24, $0, 1 ##TEST!!!

drawLoop:
sw $1, 0($2)    
addi $2, $2, 1
addi $5, $5, 1
blt $5, $4, drawLoop
noop
noop 
noop
noop
noop
addi $2, $2, 590
addi $5, $5, -50
blt $2, $3, drawLoop
noop
noop
noop
noop
noop
blt $24, $0, scoreSweep
noop
noop
noop
noop
noop
j sweep
noop
noop
noop
noop
noop


sweepDraw:
addi $18, $0, 201 #sweepDraw entirely uses memory, and state of reg 15
addi $19, $0, 300


sweep:
blt $19, $18, drawCall #will let us break out of the loop
noop
noop
noop
noop
noop
lw $1, 1($18)
lw $3, 2($18)
addi $18, $18, 3
bne $1, $0, sweep #if no arrow here, just keep sweeping
noop
noop
noop
noop
noop
bne $15, $0, setErase #if wanting to erase, then will set to erase instead
noop
noop
noop
noop
noop


drawCall:
blt $18, $19, draw #if we made have a draw to location and not out of index, then draw
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



setErase:
addi $1, $0, 0
j drawCall
noop
noop
noop
noop
noop



stall: 
noop
noop
noop
noop
noop
addi $9, $9, 1
noop
noop
noop
noop
noop
blt $9, $10, stall
noop
noop
noop
noop
noop
addi $9, $0, 0
noop
noop
noop
noop
noop
addi $6, $6, 1 #global variable, likely better to place in memory
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

checkInputsInLevel:
lw $16, 800($0) #left
addi $17, $0, 1
bne $16, $28, checkToScore
noop
noop
noop
noop 
noop
lw $16, 801($0) #up
addi $17, $0, 2
bne $16, $28, checkToScore
noop
noop
noop
noop 
noop
lw $16, 802($0) #right
addi $17, $0, 3
bne $16, $28, checkToScore
noop
noop
noop
noop
noop
lw $16, 803($0) #down
addi $17, $0, 4
bne $16, $28, checkToScore
noop
noop
noop
noop
noop
endInputCheck:
addi $16, $0, 0
addi $28, $0, 0 #reset key input state of $28
jr $31
noop
noop
noop
noop
noop


checkToScore:
addi $18, $0, 198
addi $19, $0 ,300
addi $20, $0, 65000
addi $20, $20, 65000 #highest row allowing score
addi $21, $0, 65000
addi $21, $21, 65000
addi $21, $21, 65000 #lowest row allowing score



addi $24, $0, 0 ##TEST!!!
j testDraw
noop
noop
noop
noop
noop



scoreSweep:
addi $18, $18, 3
lw $24, 0($18)
lw $25, 1($18)
lw $26, 2($18)
bne $25, $0, scoreSweep
noop
noop
noop
noop
noop
bne $17, $25, checkBounds
noop
noop
noop
noop
noop
blt $19, $18, endInputCheck
noop
noop
noop
noop
noop
j scoreSweep
noop
noop
noop
noop
noop

checkBounds:
blt $26, $20, scoreSweep #arrow too high, fails
noop
noop
noop
noop
noop
blt $21, $26, scoreSweep #arrow too low, late and fails
noop
noop
noop
noop
noop #lw $29, 900($0)
addi $29, $29, 1 #increase score by 100 or whatnot
sw $29, 900($0)
sw $17, 0($18) #storing a nonzero value, indicates to delete later in moveArrows
noop
noop 
noop
noop
noop #addi $29, $0, 0
j endInputCheck
noop
noop
noop
noop
noop



moveArrows:
addi $18, $0, 198
addi $19, $0, 300
addi $20, $0, 64000 #setting max arrow location
addi $20, $20, 64000
addi $20, $20,64000
addi $20, $20, 6400


sweep2:
addi $18, $18, 3 #largely same as in sweepDraw but avoiding 2+ jals in loops
lw $3, 0($18)
noop
noop
noop
noop
noop
bne $3, $0, moveOn
noop
noop
noop
noop
noop
j deleteArrow
noop
noop
noop
noop
noop
moveOn:
addi $3, $0, 0
lw $1, 1($18)
lw $3, 2($18)
bne $1, $0, sweep2 #if no arrow here, just keep sweeping
noop
noop
noop
noop
noop
blt $20, $3, deleteArrow
noop
noop
noop
noop
noop
addi $3, $3, 1920
sw $3, 2($18)


moveNext:
blt $18, $19, sweep2 
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


deleteArrow:
sw $0, 0($18)
sw $0, 1($18)
sw $0, 2($18)
j moveNext
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
