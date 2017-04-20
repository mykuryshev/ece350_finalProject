.text
main: 
addi $1, $0, 1 #COLOR 1

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
addi $2, $2, 641
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

addi $1, $1, 1
noop
noop
noop
noop
noop
j another
noop
noop
noop
noop
noop

another:
noop
noop
noop
noop
noop
addi $2, $0, 6100 #20 lines down on a 640 wide display
addi $3, $0, 38100 #50 lines on a 640 wide display
noop
noop
noop
noop
noop

loop1:
sw $1, 0($2)
addi $2, $2, 641
noop
noop
noop
noop
noop
blt $2, $3, loop1 
noop
noop
noop
noop
noop

addi $1, $1, 1
noop
noop
noop
noop
noop
j another1
noop
noop
noop
noop
noop

another1:
noop
noop
noop
noop
noop
addi $2, $0, 38640 #20 lines down on a 640 wide display
addi $3, $0, 65500 #50 lines on a 640 wide display
noop
noop
noop
noop
noop

loop2:
sw $1, 0($2)
addi $2, $2, 641
noop
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


addi $1, $1, 1
noop
noop
noop
noop
noop
j another2
noop
noop
noop
noop
noop

another2:
noop
noop
noop
noop
noop
addi $2, $0, 38740 #20 lines down on a 640 wide display
addi $3, $0, 65500 #50 lines on a 640 wide display
noop
noop
noop
noop
noop

loop3:
sw $1, 0($2)
addi $2, $2, 641
noop
noop
noop
noop
noop
blt $2, $3, loop3 
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
