.text
main: 
addi $1, $0, 1 #COLOR 1
addi $5, $0, 0
addi $4, $0, 50
addi $6, $0, 0
addi $7, $0, 4

beginning:
noop
noop
noop
noop
noop
addi $2, $0, 6000 #20 lines down on a 640 wide display
addi $3, $0, 38000 #50 lines on a 640 wide display
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
addi $2, $2, 591
addi $5, $5, -49
noop
noop
noop
noop
blt $2, $3, loop
noop
noop
noop
noop
addi $1, $1, 1
addi $5, $5, 0
addi $6, $6, 1
addi $2, $2, 1920
addi $3, $3, 33920
noop
noop
noop
noop
blt $6, $7, loop
noop
noop
noop
noop


clear:
addi $1, $0, 0 #COLOR 0
addi $5, $0, 0
noop
noop
noop
noop
noop
addi $2, $0, 6000 #20 lines down on a 640 wide display
addi $3, $0, 38000 #50 lines on a 640 wide display
noop
noop
noop
noop
noop

loop2:
sw $1, 0($2)
addi $2, $2, 2
addi $5, $5, 2
noop
noop
noop
noop
noop
blt $5, $4, loop2 
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
blt $2, $3, loop2
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
