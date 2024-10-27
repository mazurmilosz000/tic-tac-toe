#!/bin/bash

# initialize board
board = ( 1 2 3 4 5 6 7 8 9)

player_1 = "X"
player_2 = "O"

# indicates whose turn it is
turn = 1
game_in_progress = true
game_vs_computer = false

# score
player1_score = 0
player2_score = 0

# print board function
print_board() {
    clear # ctr + l
    echo " ${board[0]} | ${board[1]} ${board[2]} "
    echo "----------"
    echo " ${board[3]} | ${board[4]} ${board[5]} "
    echo "----------"
    echo " ${board[6]} | ${board[7]} ${board[8]} "
    echo "================="
}

print_column_2_in_score() {
    if [ $"game_vs_computer" = false ]; then
        echo "Player 2"
    else
        echo "Computer"
    fi
}

# print score function
print_score() {
    local column2 = $(print_column_2_in_score)
    echo "       -SCORES-         "
    echo "------------------------"
    echo "| Player1 | ${column2} |"
    echo "------------------------"
    echo "|   ${player1_score}    |    ${player2_score}    "
    echo "========================"
}

# player pick function
player_pick() {
    if [[ $(($turn % 2)) == 0 ]] && [[ $"game_vs_computer" = false ]]; then
        play=$player_2
        echo -n "PLAYER 2 PICK A NUMBER: "
    elif [[ $(($turn % 2)) == 1]]; then
        play=$player_2
}

