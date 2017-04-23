.text
main: 
addi $1, $0, 1 #This is block drawing
noop
noop
noop
noop
noop
addi $5, $0, 0
noop
noop
noop
noop
noop
addi $4, $0, 50
noop
noop
noop
noop
noop
addi $6, $0, 0
noop
noop
noop
noop
noop
addi $10, $0, 65000 #65000
noop
noop
noop
noop
noop
sll $10, $10, 3 #around 1 million now
noop
noop
noop
noop
noop
addi $9, $9, 0
noop
noop
noop
noop
noop

initArrowListInMem:
addi $25, $0, 0 #initial cycle to appear
noop
noop
noop
noop
noop
addi $26, $0, 1 #arrow type
noop
noop
noop
noop
noop
addi $27, $0, 38000 #arrow bot location, not really needed but had it here
noop
noop
noop
noop
noop
sw $25, 400($0)
noop
noop
noop
noop
noop
sw $26, 401($0)
noop
noop
noop
noop
noop
sw $27, 402($0)
noop
noop
noop
noop
noop
addi $25, $0, 30
noop
noop
noop
noop
noop
addi $26, $0, 3
noop
noop
noop
noop
noop
addi $27, $0, 38200
noop
noop
noop
noop
noop
sw $25, 403($0)
noop
noop
noop
noop
noop
sw $26, 404($0)
noop
noop
noop
noop
noop
sw $27, 405($0)
noop
noop
noop
noop
noop
addi $25, $0, 50
noop
noop
noop
noop
noop
addi $26, $0, 2
noop
noop
noop
noop
noop
addi $27, $0, 38100
noop
noop
noop
noop
noop
sw $25, 406($0)
noop
noop
noop
noop
noop
sw $26, 407($0)
noop
noop
noop
noop
noop
sw $27, 408($0)
noop
noop
noop
noop
noop
addi $25, $0, 100
noop
noop
noop
noop
noop
addi $26, $0, 4
noop
noop
noop
noop
noop
addi $27, $0, 38300
noop
noop
noop
noop
noop
sw $25, 409($0)
noop
noop
noop
noop
noop
sw $26, 410($0)
noop
noop
noop
noop
noop
sw $27, 411($0)
noop
noop
noop
noop
noop
addi $25, $0, 110
noop
noop
noop
noop
noop
addi $26, $0, 1
noop
noop
noop
noop
noop
addi $27, $0, 38000
noop
noop
noop
noop
noop
sw $25, 412($0)
noop
noop
noop
noop
noop
sw $26, 413($0)
noop
noop
noop
noop
noop
sw $27, 414($0)
noop
noop
noop
noop
noop
addi $25, $0, 140
noop
noop
noop
noop
noop
addi $26, $0, 2
noop
noop
noop
noop
noop
addi $27, $0, 38100
noop
noop
noop
noop
noop
sw $25, 415($0)
noop
noop
noop
noop
noop
sw $26, 416($0)
noop
noop
noop
noop
noop
sw $27, 417($0)
noop
noop
noop
noop
noop
addi $25, $0, 165
noop
noop
noop
noop
noop
addi $26, $0, 3
noop
noop
noop
noop
noop
addi $27, $0, 38200
noop
noop
noop
noop
noop
sw $25, 418($0)
noop
noop
noop
noop
noop
sw $26, 419($0)
noop
noop
noop
noop
noop
sw $27, 420($0)
noop
noop
noop
noop
noop
addi $25, $0, 180
noop
noop
noop
noop
noop
addi $26, $0, 1
noop
noop
noop
noop
noop
addi $27, $0, 38000
noop
noop
noop
noop
noop
sw $25, 421($0)
noop
noop
noop
noop
noop
sw $26, 422($0)
noop
noop
noop
noop
noop
sw $27, 423($0)
noop
noop
noop
noop
noop
addi $25, $0, 205
noop
noop
noop
noop
noop
addi $26, $0, 4
noop
noop
noop
noop
noop
addi $27, $0, 38300
noop
noop
noop
noop
noop
sw $25, 424($0)
noop
noop
noop
noop
noop
sw $26, 425($0)
noop
noop
noop
noop
noop
sw $27, 426($0)
noop
noop
noop
noop
noop
addi $25, $0, 230
noop
noop
noop
noop
noop
addi $26, $0, 2
noop
noop
noop
noop
noop
addi $27, $0, 38100
noop
noop
noop
noop
noop
sw $25, 427($0)
noop
noop
noop
noop
noop
sw $26, 428($0)
noop
noop
noop
noop
noop
sw $27, 429($0)
noop
noop
noop
noop
noop
addi $25, $0, 0
noop
noop
noop
noop
noop
addi $26, $0, 0
noop
noop
noop
noop
noop
addi $27, $0, 0
noop
noop
noop
noop
noop




beginning:
noop
noop
noop
noop
noop
addi $18, $0, 201
noop
noop
noop
noop
noop
addi $19, $0, 300
noop
noop
noop
noop
noop


inLevel:
noop
noop
noop
noop
noop
jal genArrows
noop
noop
noop
noop
noop
addi $1, $0, 1 #not really needed
noop
noop
noop
noop
noop
addi $15, $0, 1 #to draw
noop
noop
noop
noop
noop
jal sweepDraw #Draw real stuff
noop
noop
noop
noop
noop
addi $2, $0, 5800 # $2 is starting point for random block
noop
noop
noop
noop
noop
jal stall #Chill
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




draw: 
noop
noop
noop
noop
noop
addi $5, $0, 0
noop
noop
noop
noop
noop
addi $2, $3, -32000
noop
noop
noop
noop
noop
drawLoop:
noop
noop
noop
noop
noop
sw $1, 0($2)    
noop
noop
noop
noop
noop
addi $2, $2, 2
noop
noop
noop
noop
noop
addi $5, $5, 2
noop
noop
noop
noop
noop
blt $5, $4, drawLoop
noop
noop 
noop
noop
noop
addi $2, $2, 591
noop
noop
noop
noop
noop
addi $5, $5, -49
noop
noop
noop
noop
noop
blt $2, $3, drawLoop
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



sweepDraw:
noop
noop
noop
noop
noop
addi $18, $0, 201 #sweepDraw entirely uses memory, and state of reg 15
noop
noop
noop
noop
noop
addi $19, $0, 300
noop
noop
noop
noop
noop

sweep:
noop
noop
noop
noop
noop
blt $19, $18, drawCall #will let us break out of the loop
noop
noop
noop
noop
noop
lw $1, 0($18)
noop
noop
noop
noop
noop
lw $3, 1($18)
noop
noop
noop
noop
noop
addi $18, $18, 2
noop
noop
noop
noop
noop
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
noop
noop
noop
noop
noop
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
noop
noop
noop
noop
noop
addi $1, $0, 0
noop
noop
noop
noop
noop
j drawCall
noop
noop
noop
noop
noop



end: 
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
noop


moveArrows:
noop
noop
noop
noop
noop
addi $18, $0, 199
noop
noop
noop
noop
noop
addi $19, $0, 300 
noop
noop
noop
noop
noop
addi $20, $0, 64000 #setting max arrow location
noop
noop
noop
noop
noop
addi $20, $20, 64000
noop
noop
noop
noop
noop
addi $20, $20, 6400
noop
noop
noop
noop
noop
sweep2:
noop
noop
noop
noop
noop
addi $18, $18, 2
noop #largely same as in sweepDraw but avoiding 2+ jals in loops
noop
noop
noop
noop
lw $1, 0($18)
noop
noop
noop
noop
noop
lw $3, 1($18)
noop
noop
noop
noop
noop
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
noop
noop
noop
noop
noop
sw $3, 1($18)
noop
noop
noop
noop
noop
moveNext:
noop
noop
noop
noop
noop
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
noop
noop
noop
noop
noop
sw $0, 0($18)
noop
noop
noop
noop
noop
sw $0, 1($18)
noop
noop
noop
noop
noop
j moveNext
noop
noop
noop
noop
noop

genArrows:
noop
noop
noop
noop
noop
addi $20, $0, 400
noop
noop
noop
noop
noop
addi $24, $0, 500 #max stored arrow for gen in memory addr.
noop
noop
noop
noop
noop
sweep3:
noop
noop
noop
noop
noop
blt $24, $20, finishGen #if past gen list
noop
noop
noop
noop
noop
lw $21, 0($20) #cycle count necessary to load
noop
noop
noop
noop
noop
lw $22, 1($20) #arrow type, if present
noop
noop
noop
noop
noop
lw $23, 2($20) #arrow bottom location, again, if present
noop
noop
noop
noop
noop
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
addi $18, $0, 199 #reset so to not leave empty memory places
noop
noop
noop
noop
noop
addi $19, $0, 300
noop
noop
noop
noop
noop
placeArrowInMemLoop:
noop
noop
noop
noop
noop
addi $18, $18, 2 
noop
noop
noop
noop
noop
lw $25, 0($18)
noop
noop
noop
noop
noop
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
noop
noop
noop
noop
noop
sw $22, 0($18) #place arrow type in active mem
noop
noop
noop
noop
noop
sw $23, 1($18) #place arrow loc in active mem
noop
noop
noop
noop
noop
sw $0, 0($20) #remove arrow in pregen list
noop
noop
noop
noop
noop
sw $0, 1($20) #remove arrow in pregen list
noop
noop
noop
noop
noop
sw $0, 2($20) #remove arrow in pregen list
noop
noop
noop
noop
noop
finishGen:
noop
noop
noop
noop
noop
addi $21,$0,0
noop
noop
noop
noop
noop
addi $22,$0,0
noop
noop
noop
noop
noop
addi $23,$0,0
noop
noop
noop
noop
noop
jr $31 #if last arrow checked was gen'd
noop
noop
noop
noop
noop



nextArrowGen:
noop
noop
noop
noop
noop
addi $20, $20, 3
noop
noop
noop
noop
noop
j sweep3
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
