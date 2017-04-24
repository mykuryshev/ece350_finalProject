.text 
main:
addi $16, $0, 90 #enter, start from menu, used
sw $16, 804($0)
addi $16, $0, 22 #1, set slow speed in menu, used
sw $16, 805($0)
addi $16, $0, 30 #2, set slow speed in menu, used
sw $16, 806($0)
addi $16, $0, 38 #3, set slow speed in menu, used
sw $16, 807($0)
addi $16, $0, 29 #w, compare to another reg, not 28
sw $16, 808($0)
addi $16, $0, 28 #a, compare to another reg, not 28
sw $16, 809($0)
addi $16, $0, 27 #s, compare to another reg, not 28
sw $16, 810($0)
addi $16, $0, 35 #d, compare to another reg, not 28
sw $16, 811($0)
addi $16, $0, 13 #tab, reset from anywhere, NEED IN TWO PLAYER!!!
sw $16, 812($0)
addi $16, $0, 77 #p, pause from in game, NEED IN TWO PLAYER!!!
sw $16, 813($0)
addi $16, $0, 37 #4, set 1 player in menu, used
sw $16, 814($0)
addi $16, $0, 46 #5, set 2 player in menu, used
sw $16, 815($0)
addi $16, $0, 0


addi $18, $0, 38400
sll $18, $18, 3
sw $18, 5($0) #or whatnot, size of screen for screen clears
j reset
noop
noop
noop
noop
noop


jal reset
noop
noop
noop
noop
noop
j menu
noop
noop
noop
noop
noop



menu:
noop
noop
noop
noop
noop
jal setSpeed 
noop
noop
noop
noop
noop
jal setPlayers
noop
noop
noop
noop
noop
jal checkStart
noop
noop
noop
noop
noop
j menu
noop
noop
noop
noop
noop


setPlayers:
lw $16, 814($0)
bne $16, $28, setOnePlayer
noop
noop
noop
noop
noop
lw $16, 815($0)
bne $16, $28, setTwoPlayer
noop
noop
noop
noop
noop
j finishSetPlayers
noop
noop
noop
noop
noop
setOnePlayer:
addi $12, $0, 0
addi $28, $0, 0
j finishSetPlayers
noop
noop
noop
noop
noop
setTwoPlayer:
addi $12, $0, 1
addi $28, $0, 0
j finishSetPlayers
noop
noop
noop
noop
noop
finishSetPlayers:
jr $31
noop
noop
noop
noop
noop

setSpeed:
lw $16, 805($0)
bne $16, $28, setSlow
noop
noop
noop
noop
noop
lw $16, 806($0)
bne $16, $28, setMedium
noop
noop
noop
noop
noop
lw $16, 807($0)
bne $16, $28, setFast
noop
noop
noop
noop
noop
j finishSetSpeed
noop
noop
noop
noop
noop
setSlow:
addi $28, $0, 0
addi $10, $0, 65000
sll $10, $10, 3
addi $1, $0, 1 #set to green screen for easy mode
addi $2, $0, 0
lw $3, 5($0)
jal drawScreen
noop
noop
noop
noop
noop
j finishSetSpeed
noop
noop
noop
noop
noop
setMedium:
addi $28, $0, 0
addi $10, $0, 65000
sll $10, $10, 1
addi $1, $0, 5 #set yellow screen for medium
addi $2, $0, 0
lw $3, 5($0)
jal drawScreen
noop
noop
noop
noop
noop
j finishSetSpeed
noop
noop
noop
noop
noop
setFast:
addi $28, $0, 0
addi $10, $0, 20000
addi $1, $0, 4 #value to clear to menu background
addi $2, $0, 0
lw $3, 5($0)
jal drawScreen
noop
noop
noop
noop
noop
j finishSetSpeed
noop
noop
noop
noop
noop
finishSetSpeed:
addi $28, $0, 0
noop
noop
noop
j menu
noop
noop
noop
noop
noop



checkStart:
lw $16, 804($0)
blt $16, $28, start
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

start:
addi $1, $0, 0 #value to clear to menu background
addi $2, $0, 0
lw $3, 5($0)
addi $28, $0, 0
jal drawScreen
noop
noop
noop
noop
noop
addi $28, $0, 0
j inLevel
noop
noop
noop
noop
noop


inLevel:
jal checkReset
noop
noop
noop
noop
noop 
jal checkPause
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



inLevelTwoPlayer:
jal checkReset
noop
noop
noop
noop
noop
jal checkPause
noop
noop
noop
noop
noop
j inLevelTwoPlayer
noop
noop
noop
noop
noop



checkPause:
lw $16, 814($0)
bne $28, $16, pause
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



pause:
addi $28, $0, 0
pauseLoop:
bne $28, $16, endPause
noop
noop
noop
noop
noop
j pauseLoop
noop
noop
noop
noop
noop
endPause:
addi $28, $0, 0
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



checkReset:
lw $16, 813($0)
bne $16, $28, reset
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



reset:
addi $1, $0, 0 #value to clear to menu background
addi $2, $0, 0
lw $3, 5($0)
jal drawScreen
addi $28, $0, 0 
addi $10, $0, 65000
sll $10, $10, 2 #standard, slow delay
addi $12, $0, 0 #1 player
j menu
noop
noop
noop
noop
noop



drawScreen:
noop
noop
noop
sw $1, 0($2)
addi $2, $2, 1
blt $2, $3, drawScreen
noop
noop
noop
noop
noop
addi $3, $0, 0
addi $2, $0, 0
addi $1, $0, 0
jr $31
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
