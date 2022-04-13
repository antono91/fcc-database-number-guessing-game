#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# guessing game
NUMBER_GUESS() {
  RAND_NUMBER=$(( $RANDOM % 1000 + 1 ))
  TRIES=0
  # echo "$RAND_NUMBER" # for testing purposes
  echo -e "\nGuess the secret number between 1 and 1000:"
  while [ true ]
  do
    read GUESS
    TRIES=$(( TRIES+1 ))
    if [[ $GUESS =~ [0-9]+ ]]
    then
      if [[ $GUESS > $RAND_NUMBER ]]
      then
        echo -e "\nIt's lower than that, guess again::"
      elif [[ $GUESS < $RAND_NUMBER ]]
      then
        echo -e "\nIt's higher than that, guess again:"
      else [[ $GUESS == $RAND_NUMBER ]]
        echo -e "\nYou guessed it in $TRIES tries. The secret number was $RAND_NUMBER. Nice job!"
        break
      fi
    else
      TRIES=$(( TRIES-1 ))
      echo -e "\nThat is not an integer, guess again:"
    fi
  done
}

# Enter username
echo "Enter your username:"
read USERNAME
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

# Check if user exits
if [[ $USER_ID ]]
then
  # get user information
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID")
  # greet user
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  # insert user into database
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  echo "$INSERT_USER_RESULT, $USER_ID"

  # greet user
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
fi

# play game
NUMBER_GUESS

# update best game
if [[ $TRIES < $BEST_GAME || -z $BEST_GAME ]]
then
  UPDATE_BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game=$TRIES WHERE user_id=$USER_ID")
fi

# add one to games played
UPDATE_GAMES_RESULT=$($PSQL "UPDATE users SET games_played=games_played+1 WHERE user_id=$USER_ID")