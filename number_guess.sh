#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo Enter your username:
read NAME
USER_INFO=$($PSQL "select users.user_id, games_played, min(guesses) from users right join games on users.user_id = games.user_id where user_name = '$NAME' group by users.user_id")

if [[ -z $USER_INFO ]]
then
  RESULTS=$($PSQL "insert into users(user_name, games_played) values('$NAME', 0)")
  USER_ID=$($PSQL "select user_id from users where user_name = '$NAME'")
  if [[ -z USER_ID ]]
  then
    #BIG PROBLEMS
    echo INSERT FAILURE
  else
    echo "Welcome, $NAME! It looks like this is your first time here."
    GAMES_PLAYED=0
    GUESSES=0
  fi
else
  echo $USER_INFO | sed 's/|/ | /g' | while read USER_ID BAR GAMES_PLAYED BAR GUESSES
  do
    echo "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $GUESSES guesses."
  done
fi

if [[ -z USER_ID ]]
then
  echo Exiting bad entry
else
  LEVEL=1000
  NUMBER=$(($RANDOM % $LEVEL))
  ATTEMPTS=0;

  echo "Guess the secret number between 1 and 1000:"
  while [[ $GUESS != $NUMBER ]]
  do
    ((ATTEMPTS++))
    read GUESS
    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"    
    elif [[ $GUESS > $NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    elif [[ $GUESS < $NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    else
      echo "You guessed it in $ATTEMPTS tries. The secret number was $NUMBER. Nice job!"
    fi
  done

  ((GAMES_PLAYED++))
fi

USER_INFO=$($PSQL "select user_id, games_played from users where user_name = '$NAME'")
echo $USER_INFO | sed 's/|/ | /g' | while read USER_ID BAR GAMES_PLAYED 
do
  ((GAMES_PLAYED++))
  RESULTS=$($PSQL "update users set games_played = $GAMES_PLAYED where user_id = $USER_ID")
  RESULTS=$($PSQL "insert into games(user_id, guesses) values($USER_ID, $ATTEMPTS)")
done
