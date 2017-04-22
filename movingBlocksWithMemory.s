.text
main: 
addi $1, $0, 1 #COLOR 1
addi $5, $0, 0
addi $4, $0, 50
addi $6, $0, 0
addi $7, $0, 200

addi $10, $0, 65000 #65000
sll $10, $10, 4
addi $9, $9, 0

beginning:
noop
noop
noop
noop
noop
addi $2, $0, 6000 #20 lines down on a 640 wide display
addi $3, $0, 38000 #50 lines on a 640 wide display
addi $11, $0, 6100
addi $12, $11, 32000
noop
noop
noop
noop
noop
sw $2, 200($0)
sw $3, 201($0)
sw $11, 202($0)
sw $12, 203($0)
noop
noop
noop
noop
noop
addi $2, $0, 0
addi $3, $0, 0
addi $11, $0, 0
addi $12, $0, 0
noop
noop
noop
noop
noop
lw $2, 200($0)
lw $3, 201($0)
lw $11, 202($0)
lw $12, 203($0)
noop
noop
noop
noop
noop

loop:
sw $1, 0($2)
sw $1, 0($11)
addi $2, $2, 2
addi $11, $11, 2
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
addi $11, $11, 591
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
addi $2, $3, -32000 #20 lines down on a 640 wide display
addi $11, $12, -32000
noop
noop
noop
noop
noop

loop2:
sw $1, 0($2)
sw $1, 0($11)
addi $2, $2, 1
addi $11, $11, 1
addi $5, $5, 1
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
addi $2, $2, 590
addi $11, $11, 590
addi $5, $5, -50
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

addi $1, $0, 1 #color back to nonwhite
addi $6, $6, 3
addi $5, $0, 0
addi $3, $3, 1920
addi $12, $12, 1920
addi $2, $3, -32000
addi $11, $12, -32000
noop
noop
noop
noop
blt $6, $7, loop
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
j beginning
noop
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
