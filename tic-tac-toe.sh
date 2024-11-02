#!/bin/bash

# Initialize board
board=(1 2 3 4 5 6 7 8 9)

player_1="X"
player_2="O"

# Indicates whose turn it is
turn=1
game_in_progress=true
game_vs_computer=true

# Score
player1_score=0
player2_score=0

# Save file location
save_file="tic_tac_toe_save.txt"
is_game_loaded_from_file=false

# Print board function
print_board() {
    clear # ctrl + l
    echo " ${board[0]} | ${board[1]} | ${board[2]} "
    echo "----------"
    echo " ${board[3]} | ${board[4]} | ${board[5]} "
    echo "----------"
    echo " ${board[6]} | ${board[7]} | ${board[8]} "
    echo "================="
}

clear_board() {
    board=(1 2 3 4 5 6 7 8 9)
}

print_column_2_in_score() {
    if [ "$game_vs_computer" == false ]; then
        echo "Player 2"
    else
        echo "Computer"
    fi
}

# Print score function
print_score() {
    local column2=$(print_column_2_in_score)
    echo "       -SCORES-         "
    echo "------------------------"
    echo "| Player1 | ${column2} |"
    echo "------------------------"
    echo "|   ${player1_score}    |    ${player2_score}    "
    echo "========================"
}

# Function to check if a save file exists
save_file_exists() {
    if [[ -f "$save_file" ]]; then
        return 0
    else
        return 1
    fi
}

clear_save() {
    if [[ -f "$save_file" ]]; then
        rm "$save_file"
    fi
}

# Save game function
save_game() {
    echo "${board[@]}" > "$save_file"
    echo "$turn" >> "$save_file"
    echo "$player1_score" >> "$save_file"
    echo "$player2_score" >> "$save_file"
    echo "$game_vs_computer" >> "$save_file"
    echo "Game saved successfully!"
}

load_game() {
    if [[ -f "$save_file" ]]; then
        # Read the first line into a single string
        local line
        read -r line < "$save_file" # Read the first line containing the board
        
        # Split the string into the board array using the read command
        IFS=' ' read -r -a board <<< "$line"
        
        # Read subsequent game state from the file
        exec 3< "$save_file" # Open the file descriptor for reading
        read -r board <&3 # Read board from the first line
        read -r turn <&3 # Read turn from the second line
        read -r player1_score <&3 # Read player1_score from the third line
        read -r player2_score <&3 # Read player2_score from the fourth line
        read -r game_vs_computer <&3 # Read game_vs_computer from the fifth line
        exec 3<&- # Close file descriptor 3

        echo "Game loaded successfully!"
        game_in_progress=true
        print_board # Print the board after loading
    else
        echo "No saved game found."
        is_game_loaded_from_file=false
    fi
}



# Load saved game prompt
load_game_prompt() {
    if save_file_exists; then 
        echo "Do you want to load saved game? [y/n]: "
        read -r load_choice
        if [[ "$load_choice" == "y" || "$load_choice" == "Y" ]]; then
            load_game
            is_game_loaded_from_file=true
        elif [[ "$load_choice" == "n" || "$load_choice" == "N" ]]; then
            is_game_loaded_from_file=false
            clear_save
        else
            echo "Not a valid choice!"
            load_game_prompt
        fi
    fi
}

# Player pick function
pick() {
    if [[ $((turn % 2)) == 0 && "$game_vs_computer" == true ]]; then
        computer_pick
    else
        player_pick
    fi
}

computer_pick() {
    # Generate random move for the computer
    while true; do
        random_number=$(( RANDOM % 9 )) # Random number between 0 and 8
        if [[ ${board[$random_number]} =~ ^[0-9]+$ ]]; then
            board[$random_number]=$player_2
            ((turn++))
            break
        fi
    done
}

player_pick() {
    if [[ $((turn % 2)) == 0 && "$game_vs_computer" == false ]]; then
        current_character=$player_2
        echo -n "PLAYER 2 PICK A NUMBER: "
    elif [[ $((turn % 2)) == 1 ]]; then
        current_character=$player_1
        echo -n "PLAYER 1 PICK A NUMBER: "
    fi

    read -r number
    square_value=${board[$((number - 1))]}

    # Check if input is valid and the square is not occupied
    if [[ ! $number =~ ^[1-9]$ ]] || [[ ! $square_value =~ ^[0-9]+$ ]]; then
        echo "Not a valid number"
        player_pick
    else
        board[$((number - 1))]=$current_character
        ((turn++))
    fi
}

# Helper function that checks if there are 3 consecutive symbols of the same value
check_match() {
    if [[ ${board[$1]} == "${board[$2]}" && ${board[$2]} == "${board[$3]}" ]]; then
        game_in_progress=false
        if [[ ${board[$1]} == 'X' ]]; then
            echo "Player one wins!"
            ((player1_score++))
        else
            if [ "$game_vs_computer" == false ]; then
                echo "Player two wins!"
            else
                echo "Computer wins!"
            fi
            ((player2_score++))
        fi
    fi
}

check_winner() {
    check_match 0 1 2
    check_match 3 4 5
    check_match 6 7 8
    check_match 0 4 8
    check_match 2 4 6
    check_match 0 3 6
    check_match 1 4 7
    check_match 2 5 8

    if [[ $turn -gt 9 && $game_in_progress == true ]]; then 
        game_in_progress=false
        echo "It's a draw!"
    fi
}

select_game_mode() {
    echo "Welcome to Tic-Tac-Toe"
    echo "Select game mode: "
    echo "1) Player vs Player"
    echo "2) Player vs Computer"
    read -r game_mode

    if [[ $game_mode == "1" ]]; then
        game_vs_computer=false
    elif [[ $game_mode == "2" ]]; then
        game_vs_computer=true
    else
        echo "Not a valid game mode!"
        start_game
    fi
}

start_game() {
    load_game_prompt

    if [[ $is_game_loaded_from_file == false ]]; then
        select_game_mode
    else
        echo "Continuing from saved game..."
    fi
    main_loop
}

# Main loop
main_loop() {
    turn=1
    clear_board
    print_board
    while $game_in_progress
    do
        pick
        print_board
        check_winner
    done
    print_score
    play_again
}

save_game_prompt() {
    echo "Do you want to save game? [y/n]: "
    read -r save_game_choice

    if [[ "$save_game_choice" == "y" || "$save_game_choice" == "Y" ]]; then
        save_game
    elif [[ "$save_game_choice" == "n" || "$save_game_choice" == "N" ]]; then
        clear_save
    else 
        echo "Not a valid answer!"
        save_game_prompt
    fi
}

play_again() {
    echo "Do you want to play again? [y/n]: "
    read -r answer

    if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
        game_in_progress=true
        turn=1
        clear_board # Reset the board for a new game
        main_loop
    
    elif [[ "$answer" == "n" || "$answer" == "N" ]]; then
        save_game_prompt
        return 0
    else
        echo "Not a valid answer!"
        play_again
    fi
}

# Start the game for the first time
start_game
