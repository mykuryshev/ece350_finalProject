.text
main: 
addi $1, $0, 1 #COLOR 1
addi $5, $0, 0
addi $4, $0, 50
addi $6, $0, 0

addi $10, $0, 65000 #65000
sll $10, $10, 4
addi $9, $9, 0

setInitialLocation:
addi $11, $0, 1 #arrow type
addi $12, $0, 6000 #arrowStartLoc
addi $13, $12, 32000 #arrowEndLoc
addi $2, $0, 1 #like loop counter here but 3 at a time and indexes memory
addi $3, $0, 12 #max spot in memory setting atm
initLocLoop:
noop
noop
noop
noop
noop
sw $11, 0($2)
sw $12, 1($2)
sw $13, 2($2)
noop
noop
noop
noop
noop
addi $2, $2, 3
addi $11, $11, 1
addi $12, $12, 100
addi $13, $13, 100
blt $2, $3, initLocLoop
noop
noop
noop
noop
noop
addi $2, $0, 0
addi $3, $0, 0
noop
noop
noop
noop
noop

initArrowListInMem:
addi $25, $0, 0 #initial cycle to appear
addi $26, $0, 1 #arrow type
addi $27, $0, 38000 #arrow bot location, not really needed but had it here
noop
noop
noop
noop
noop
sw $25, 400($0)
sw $26, 401($0)
sw $27, 402($0)
noop
noop
noop
noop
noop
addi $25, $0, 25
addi $26, $0, 2
addi $27, $0, 38100
noop
noop
noop
noop
noop
sw $25, 403($0)
sw $26, 404($0)
sw $27, 405($0)
noop
noop
noop
noop
noop
addi $25, $0, 50
addi $26, $0, 3
addi $27, $0, 38200
noop
noop
noop
noop
noop
sw $25, 406($0)
sw $26, 407($0)
sw $27, 408($0)
noop
noop
noop
noop
noop
addi $25, $0, 75
addi $26, $0, 4
addi $27, $0, 38300
noop
noop
noop
noop
noop
sw $25, 409($0)
sw $26, 410($0)
sw $27, 411($0)
noop
noop
noop
noop
noop
addi $25, $0, 0
addi $26, $0, 0
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
addi $19, $0, 300



inLevel:
jal genArrows
noop
noop
noop
noop
noop
addi $1, $0, 1 #not really needed
addi $15, $0, 1 #to draw
jal sweepDraw
noop
noop
noop
noop
noop
jal stall
noop
noop
noop
noop
noop
addi $1, $0, 0 #not really needed
addi $15, $0, 0 #toErase
jal sweepDraw
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
j beginning
noop
noop
noop
noop
noop



draw: 
addi $5, $0, 0
addi $2, $3, -32000
noop
noop
noop
noop
noop
drawLoop:
sw $1, 0($2)
noop
noop
noop
noop
noop
addi $2, $2, 2
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
addi $9, $9, 1
noop
noop
noop
noop
blt $9, $10, stall
noop
noop
noop
noop
addi $9, $0, 0
addi $6, $6, 1 #global variable, likely better to place in memory
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
addi $18, $0, 201
addi $19, $0, 300
sweep:
blt $19, $18, drawCall #will let us break out of the loop
noop
noop
noop
noop
noop
lw $1, 0($18)
lw $3, 1($18)
noop
noop
noop
noop
noop
addi $18, $18, 2
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



moveArrows:
addi $18, $0, 201
addi $19, $0, 300 
addi $20, $0, 64000 #setting max arrow location
addi $20, $20, 64000
addi $20, $20, 6400
noop
noop
noop
sweep2: 
noop #largely same as in sweepDraw but avoiding 2+ jals in loops
noop
noop
noop
lw $1, 0($18)
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
addi $18, $18, 2
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
addi $20, $0, 400
addi $24, $0, 500 #max stored arrow for gen in memory addr.
noop
noop
noop
noop
noop
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
addi $19, $0, 300
noop
noop
noop
noop
noop
placeArrowInMemLoop:
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
sw $22, 0($18) #place arrow type in active mem
sw $23, 1($18) #place arrow loc in active mem
noop
noop
noop
noop
noop
sw $0, 0($20) #remove arrow in pregen list
sw $0, 1($20) #remove arrow in pregen list
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
jr $31 #if last arrow checked was gen'd
noop
noop
noop
noop
noop



nextArrowGen:
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


.data
wow: .word 0x0000B504
mystring: .string ASDASDASDASDASDASD
var: .char Z
label: .char A
heapsize: .word 0x00000000
myheap: .word 0x00000000
