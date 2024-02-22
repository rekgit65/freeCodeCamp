#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table -t --no-align -c"

MAIN_MENU ()
{
  if [[ -z $1 ]]
  then
    echo -e "Please provide an element as an argument."
  else
    if [[ ! $1 =~ ^[0-9]+$ ]]
    then
      # text string
      SYMBOL_MENU $1
    else
      # numeric so try atomic number
      NUMBER_MENU $1
    fi
  fi
}

NUMBER_MENU ()
{
  ATOM_NUMBER_RETURN=$($PSQL "select e1.atomic_number, e1.name, e1.symbol, p1.atomic_mass, p1.melting_point_celsius, p1.boiling_point_celsius, t1.type from elements as e1 left join properties as p1 on e1.atomic_number = p1.atomic_number left join types as t1 on p1.type_id = t1.type_id where e1.atomic_number = $1")
  if [[ -z $ATOM_NUMBER_RETURN ]]
  then
    echo "I could not find that element in the database."
  else
    DISPLAY_MENU $ATOM_NUMBER_RETURN
  fi
}

SYMBOL_MENU ()
{
  ATOM_SYMBOL_RETURN=$($PSQL "select e1.atomic_number, e1.name, e1.symbol, p1.atomic_mass, p1.melting_point_celsius, p1.boiling_point_celsius, t1.type from elements as e1 left join properties as p1 on e1.atomic_number = p1.atomic_number left join types as t1 on p1.type_id = t1.type_id where e1.symbol = '$1'")
  if [[ -z $ATOM_SYMBOL_RETURN ]]
  then
    FULL_NAME_MENU $1
  else
    DISPLAY_MENU $ATOM_SYMBOL_RETURN
  fi
}

FULL_NAME_MENU ()
{
  ATOM_SYMBOL_RETURN=$($PSQL "select e1.atomic_number, e1.name, e1.symbol, p1.atomic_mass, p1.melting_point_celsius, p1.boiling_point_celsius, t1.type from elements as e1 left join properties as p1 on e1.atomic_number = p1.atomic_number left join types as t1 on p1.type_id = t1.type_id where e1.name = '$1'")
  if [[ -z $ATOM_SYMBOL_RETURN ]]
  then
    echo "I could not find that element in the database."
  else
    DISPLAY_MENU $ATOM_SYMBOL_RETURN
  fi
}

DISPLAY_MENU ()
{
    echo "$1" | sed 's/|/ | /g' | while read ANUM BAR ANAME BAR ASYM BAR AMASS BAR MELT BAR BOIL BAR TYPE
    do
      echo "The element with atomic number $ANUM is $ANAME ($ASYM). It's a $TYPE, with a mass of $AMASS amu. $ANAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
    done 
}

MAIN_MENU $1
