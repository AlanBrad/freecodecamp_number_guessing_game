#!/bin/bash

#Number Guessing Game

PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

NUMBER=$(( RANDOM % 1000 + 1 ))
NEW_GUESSES=1
GUESS=0

#get username
echo Enter your username:
read USERNAME

#find username
USERS=$($PSQL "SELECT user_id, username, games, guesses FROM users WHERE username='$USERNAME'")

if [[ -z $USERS ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else
    read USER_ID BAR USERNAME BAR GAMES BAR GUESSES <<< $USERS
    if [[ $GAMES -eq 1 ]]
      then
        GAMES_MSG="game"
      else
        GAMES_MSG="games"
    fi
    if [[ $GUESSES -eq 1 ]]
      then
        GUESSES_MSG="guess"
      else
        GUESSES_MSG="guesses"
    fi
    echo "Welcome back, $USERNAME! You have played $GAMES $GAMES_MSG, and your best game took $GUESSES $GUESSES_MSG."
fi

#guess until match
GUESS_NUMBER() {
  if [[ $1 ]]
    then
      echo "$1"
  fi

  read GUESS
  #test if numeric
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      GUESS_NUMBER "That is not an integer, guess again:"
    else
      NEW_GUESSES=$((NEW_GUESSES + 1 ))
      if [[ $GUESS -gt $NUMBER ]]
        then
          GUESS_NUMBER "It's lower than that, guess again:"
        elif [[ $GUESS -lt $NUMBER ]]
          then
            GUESS_NUMBER "It's higher than that, guess again:"
        else
          NEW_GUESSES=$((NEW_GUESSES - 1 ))
          if [[ $NEW_GUESSES -eq 1 ]]
            then
              NEW_TRIES_MSG="try"
            else
              NEW_TRIES_MSG="tries"
          fi
          echo "You guessed it in $NEW_GUESSES $NEW_TRIES_MSG. The secret number was $NUMBER. Nice job!"
          return
      fi
  fi
}

GUESS_NUMBER "Guess the secret number between 1 and 1000:"

#if new user then insert new row
if [[ -z $USERS ]]
  then
    INSERT_RESULT=$($PSQL "INSERT INTO users(username, games, guesses) VALUES('$USERNAME', 1, $NEW_GUESSES)")
  else
    #update existing row
    if [[ $NEW_GUESSES -ge $GUESSES ]]
      then
        NEW_GUESSES=$GUESSES
    fi
    UPDATE_RESULT=$($PSQL "UPDATE users SET games=games + 1, guesses=$NEW_GUESSES WHERE user_id = $USER_ID")
fi
