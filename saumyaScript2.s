.text
main: 
addi $1, $0, 1 #COLOR 1

addi $10, $0, 6000
addi $11, $0, 38000
noop
noop
noop
noop
noop
add $2, $0, $10 
add $3, $0, $11 #50 lines on a 640 wide display
addi $4, $0, 0
addi $5, $0, 50
noop
noop
noop
noop
noop

loop:
sw $1, 0($2)
addi $2, $2, 640
noop
noop
noop
noop
noop
blt $2, $3, loop 
noop
noop
noop
noop
noop

addi $2, $2, -31999 #Reduce by 32000, add 1
addi $3, $3, 1
addi $4, $4, 1
noop
noop
noop
noop
noop
blt $4, $5, loop
noop
noop
noop
noop
noop
noop #Doing other stuff now


addi $6, $0, 7000 
addi $7, $0, 7050

noop
noop
noop
noop
noop

another:
sw $1, 0($6)
addi $6, $6, 1
noop
noop
noop
noop
noop
blt $6, $7, another 
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
