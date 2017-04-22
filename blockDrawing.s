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
sll $10, $10, 4 #around 1 million now
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
noop
noop
noop
noop
noop
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
sw $26, 201($0)
noop
noop
noop
noop
noop
sw $27, 202($0)
noop
noop
noop
noop
noop
addi $25, $0, 25
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
sw $25, 403($0)
noop
noop
noop
noop
noop
sw $26, 203($0)
noop
noop
noop
noop
noop
sw $27, 204($0)
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
sw $25, 406($0)
noop
noop
noop
noop
noop
sw $26, 205($0)
noop
noop
noop
noop
noop
sw $27, 206($0)
noop
noop
noop
noop
noop
addi $25, $0, 75
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
sw $26, 207($0)
noop
noop
noop
noop
noop
sw $27, 208($0)
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
noop 
addi $2, $2, 44200
noop
noop
noop
noop
noop
lw $27, 202($0)
noop
noop
noop
noop
noop
addi $27, $27, 1920
noop
noop
noop
noop
noop
sw $27, 202($0)
noop
noop
noop
noop
noop
sw $0, 203($0)
noop
noop
noop
noop
noop
sw $0, 205($0)
noop
noop
noop
noop
noop
sw $0, 207($0)
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



drawBlock:
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
addi $26, $0, 0
noop
noop
noop
noop
noop
addi $1, $0, 1
noop
noop
noop
noop
noop
addi $27, $0, 100

loopABC:
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
blt $5, $4, loopABC
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
addi $2, $2, 591
noop
noop
noop
noop
noop
addi $26, $26, 1 
noop
noop
noop
noop
noop
blt $26, $27, loopABC
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
blt $9, $10, stall
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





.data
wow: .word 0x0000B504
mystring: .string ASDASDASDASDASDASD
var: .char Z
label: .char A
heapsize: .word 0x00000000
myheap: .word 0x00000000
