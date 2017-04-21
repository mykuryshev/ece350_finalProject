.text
main: 
addi $1, $0, 1 #COLOR 1
addi $5, $0, 0
addi $4, $0, 50
addi $6, $0, 0
addi $7, $0, 200
addi $18, $0, 4
sll $18, $18, 8
sll $18, $18, 8
addi $13, $0, 1

addi $10, $0, 50000 #65000
sll $10, $10, 4
addi $9, $0, 0

addi $20, $0, 5800 #arow 1
addi $21, $0, 5900 #arrow 2

beginning:
noop
noop
noop
noop
noop
addi $15, $0, 0
blt $13, $15, check2
noop
noop
noop
noop
noop
addi $2, $20, 0 #20 lines down on a 640 wide display
addi $3, $20, 32000 #50 lines on a 640 wide display
jal loop
noop
noop
noop
noop
noop
addi $20, $20, 1920
check2:
addi $15, $0, 50
blt $13, $15, check3
noop
noop
noop
noop
noop
addi $2, $21, 0
addi $3, $21, 32000
jal loop
noop
noop
noop
noop
noop
addi $21, $21, 1920
check3:
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
jal erase
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



loop:
sw $1, 0($2)
addi $2, $2, 2
addi $5, $5, 2
noop
noop
noop
noop
noop
blt $5, $4, loop 
noop
noop 
noop
noop
noop
addi $2, $2, 591
addi $5, $5, -49
blt $2, $3, loop
noop
noop
noop
noop
noop
addi $5, $0, 0
jr $31
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
noop
blt $9, $10, stall
noop
noop
noop
noop
noop
addi $9, $0, 0
addi $13, $13, 1
jr $31 
noop
noop
noop
noop
noop




erase:
addi $17, $0, 0
noop
noop
noop
noop

loop2:
sw $0, 0($17)
addi $17, $17, 2
noop
noop
noop
noop
noop
blt $17, $18, loop2 
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
