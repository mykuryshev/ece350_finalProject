.text 
main:

addi $28, $0, 0 #will store scan code for valid key inputs from hardware
addi $9, $9, 0
addi $10, $10, 65000
sll $10, $10, 6 #4 times longer stall for testDrawing

addi $16, $0, 107 #left
sw $16, 800($0)
addi $16, $0, 117 #up
sw $16, 801($0)
addi $16, $0, 116 #right
sw $16, 802($0)
addi $16, $0, 114 #down
sw $16, 803($0)
addi $16, $0, 0


inLevel:
jal stall
noop
noop
noop
noop
noop
jal eraseBlock
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



stall:
sw $31, 1000($0)

stallSweep:
addi $9, $9, 1
bne $28, $0, continueStall 
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
continueStall:
blt $9, $10, stallSweep
noop
noop
noop
noop
noop
lw $31, 1000($0)
jr $31
noop
noop
noop
noop
noop


checkInputsInLevel:
lw $16, 800($0) #left
addi $1, $0, 1
bne $16, $28, drawBlock
noop
noop
noop
noop
noop
lw $16, 801($0) #up
addi $1, $0, 2
bne $16, $28, drawBlock
noop
noop
noop
noop
noop
lw $16, 802($0) #right
addi $1, $0, 3
bne $16, $28, drawBlock
noop
noop
noop
noop
noop
lw $16, 803($0) #down
addi $1, $0, 4
bne $16, $28, drawBlock
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



drawBlock: 
addi $4, $0, 50
addi $5, $0, 0
addi $3, $0, 38000
addi $2, $3, -32000

drawLoop1:
sw $1, 0($2)    
addi $2, $2, 2
addi $5, $5, 2
blt $5, $4, drawLoop1
noop
noop 
noop
noop
noop
addi $2, $2, 591
addi $5, $5, -49
blt $2, $3, drawLoop1
noop
noop
noop
noop
noop
j endInputCheck 
noop
noop
noop
noop
noop


eraseBlock:
addi $1, $0, 0
addi $4, $0, 50
addi $5, $0, 0
addi $3, $0, 38000
addi $2, $3, -32000

drawLoop2:
sw $1, 0($2)    
addi $2, $2, 2
addi $5, $5, 2
blt $5, $4, drawLoop2
noop
noop 
noop
noop
noop
addi $2, $2, 591
addi $5, $5, -49
blt $2, $3, drawLoop2
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





end:
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
