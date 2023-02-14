#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo "$($PSQL "TRUNCATE games, teams")"
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WIN_GOALS OPP_GOALS
do
  if [[ $YEAR != year ]]
  then
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

    if [[ -z $WINNER_ID ]]
    then
      INSERT_TEAM=$($PSQL "INSERT INTO teams (name) VALUES ('$WINNER')")
      if [[ $INSERT_TEAM == "INSERT 0 1" ]]
      then
        WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
        echo Inserted into teams, $WINNER
      fi
    fi

    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    if [[ -z $OPPONENT_ID ]]
    then
      INSERT_TEAM=$($PSQL "INSERT INTO teams (name) VALUES ('$OPPONENT')")
      if [[ $INSERT_TEAM == "INSERT 0 1" ]]
      then
        OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
        echo Inserted into teams, $OPPONENT
      fi
    fi
    GAME_ID=$($PSQL "SELECT game_id FROM games WHERE year = $YEAR AND round = '$ROUND' AND winner_id = '$WINNER_ID' AND opponent_id = '$OPPONENT_ID' AND winner_goals = $WIN_GOALS AND opponent_goals = $OPP_GOALS")
    if [[ -z $GAME_ID ]]
    then
      echo Game not registered
      INSERT_GAME=$($PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', '$WINNER_ID', '$OPPONENT_ID', $WIN_GOALS, $OPP_GOALS)")
      if [[ $INSERT_GAME == "INSERT 0 1" ]]
      then
        echo Inserted into games
      fi
    fi
  fi
done
