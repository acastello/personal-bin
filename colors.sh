#!/bin/bash

ARGV=( "$@" )

if [ $# -gt 0 ] ; then
    BARWIDTH=0
    for i in {0..8} ; do
        FGNAMES[$i]="${ARGV[$(($i % $#))]}"
        BARWIDTH=$(($BARWIDTH + ${#FGNAMES[$i]} + 2))
    done
else
    COLS=$(tput cols)
    if [ $COLS -gt 90 ] ; then
        FGNAMES=(' default' ' black ' '  red  ' ' green ' ' yellow' '  blue ' 'magenta' '  cyan ' ' white ')
        BARWIDTH=$((1+9*9))
    elif [ $COLS -gt 60 ] ; then
        FGNAMES=(' def ' ' bla ' ' red ' ' gre ' ' yel ' ' blu ' ' mag ' ' cya ' ' whi ')
        BARWIDTH=$((7*9))
    else
        FGNAMES=('def' 'bla' 'red' 'gre' 'yel' 'blu' 'mag' 'cya' 'whi')
        BARWIDTH=$((5*9))
    fi
fi
BGNAMES=('DFT' 'BLK' 'RED' 'GRN' 'YEL' 'BLU' 'MAG' 'CYN' 'WHT')
        
BAR=$(printf "─%.0s" $(seq 1 $BARWIDTH))
echo "     ┌─${BAR}─┐"
for b in $(seq 0 8); do
    if [ "$b" -gt 0 ]; then
      bg=$(($b+39))
    fi

    echo -en "\033[0m ${BGNAMES[$b]} │ "
    for f in $(seq 0 8); do
      echo -en "\033[${bg}m\033[$(($f+29))m ${FGNAMES[$f]} "
    done
    echo -en "\033[0m │"

    echo -en "\033[0m\n\033[0m     │ "
    for f in $(seq 0 8); do
      echo -en "\033[${bg}m\033[1;$(($f+29))m ${FGNAMES[$f]} "
    done
    echo -en "\033[0m │"
        echo -e "\033[0m"

  if [ "$b" -lt 8 ]; then
    echo "     ├─${BAR}─┤"
  fi
done
echo "     └─${BAR}─┘"
