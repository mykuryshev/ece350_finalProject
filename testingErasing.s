.text
main: 
addi $1, $0, 1 #COLOR 1
addi $5, $0, 0
addi $4, $0, 50
addi $6, $0, 0

addi $10, $0, 65000 #65000
sll $10, $10, 4
addi $9, $9, 0
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
noop
noop
noop
noop
noop
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
addi $15, $0, 0 #toErase
jal sweepDraw #DOES NOT ERASE, CURRENTLY NOT OPERATIONAL
noop
noop
noop
noop
noop
jal stall #JUST TO MAKE ERASES MORE NOTICEABLE IF WE GET IT, TESTING ONLY
noop
noop
noop
noop
noop #jal moveArrows #would be around here
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
noop
noop
noop
noop
noop
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
noop
noop
noop
noop
noop
addi $18, $0, 201
addi $19, $0, 300
noop
noop
noop
noop
noop
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
