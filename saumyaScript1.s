.text
main: 

addi $1, $0, 1 #COLOR 1
addi $2, $0, 6000 #20 lines down on a 640 wide display
addi $3, $0, 6050 #50 lines on a 640 wide display

noop
noop
noop
noop
noop

loop:
sw $1, 0($2)
addi $2, $2, 1
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

addi $2, $2, 1230
addi $3, $3, 1280

noop
noop
noop
noop
noop

anotherone:
sw $1, 0($2)
addi $2, $2, 1
noop
noop
noop
noop
noop
blt $2, $3, anotherone
j end

end:
noop
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
