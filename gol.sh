#!/bin/bash

# Random returns a random number between 0 and 1.
random() {
   NUM=${RANDOM}/32767
   bc -l <<< "scale=2 ; $NUM"
}

# Initializes the grid for the game.
initgrid() {
   echo "Initializing grid . . ."
   for ((x=0;x<$WIDTH;x++)); do
      # echo "Filling column $x."
      for ((y=0;y<$HEIGHT;y++)); do
         num=`random`
         key="${x},${y}"
         # echo "$key"
         if (( $(echo "$num <= $SPAWNCHANCE" | bc -l) )); then # Took this from https://stackoverflow.com/questions/8654051/how-to-compare-two-floating-point-numbers-in-bash
            # echo "Spawning a cell for $key."
            grid["$key"]=1
         else
            # echo "Creating an empty cell."
            grid["$key"]=0
         fi
         # echo ${GRID[$key]}
      done
   done
   # for i in "${!GRID[@]}"; do
   #    echo "key  : $i"
   #    echo "value: ${GRID[$i]}"
   # done
}

# Draws the border for the game.
drawborder() {
   # Draw the top border.
   tput setab 7 # Set background color to white.
   tput cup $(($FIRSTROW + $BUFFER)) $FIRSTCOL # Move the cursor.
   x=$FIRSTCOL
   while [ $x -le $LASTCOL ];
   do
      printf "%b" "$WALL"
      x=$((x + 1));
   done

   # Draw the sides.
   y=$FIRSTROW
   while [ $y -le $LASTROW ];
   do
      tput cup $(($y + $BUFFER)) $FIRSTCOL; printf "%b" "$WALL"
      tput cup $(($y + $BUFFER)) $(($LASTCOL+1)); printf "%b" "$WALL"
      y=$((y + 1));
   done

   # Draw the bottom border.
   tput cup $(($LASTROW + $BUFFER)) $FIRSTCOL
   x=$FIRSTCOL
   while [ $x -le $LASTCOL ];
   do
      printf "%b" "$WALL"
      x=$((x + 1));
   done

   tput sgr0 # Reset text attributes.
}

# Draws the cells for the game.
drawcells() {
   tput setab 3

   for ((x=0;x<$WIDTH;x++)); do
      for ((y=0;y<$HEIGHT;y++)); do
         # alive=$((GRID["$x,$y"]))
         # sleep 0.3
         key="${x},${y}"
         # echo $key
         alive=${GRID[$key]}
         # echo $alive
         if [ $alive -eq 1 ]; then
            tput cup $(($y + $FIRSTROW + $BUFFER + 1)) $(($x + $FIRSTCOL + 1))
            printf "%b" "$CELL"
         fi
      done
   done

   tput sgr0 # Reset text attributes.
}
                        
WALL=" "
CELL=" "   

# K="baz"
# MYMAP[$K]=quux       # Use a variable as key to put a value into an associative array
# echo ${MYMAP[$K]}    # Use a variable as key to extract a value from an associative array
# echo ${MYMAP[baz]}                                         
  
BUFFER=11   

FIRSTROW=3
LASTROW=10 
# LASTROW=35
HEIGHT=$(($LASTROW - $FIRSTROW))                     
FIRSTCOL=3
LASTCOL=10                          
# LASTCOL=67
WIDTH=$(($LASTCOL - $FIRSTCOL))
SPAWNCHANCE=0.15

declare -a LASTGRID
declare -a GRID

echo -n "This is a simulation of the Conway's Game of Life:

   1. Any live cell with fewer than two live neighbours dies, as if by underpopulation.
   2. Any live cell with two or three live neighbours lives on to the next generation.
   3. Any live cell with more than three live neighbours dies, as if by overpopulation.
   4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

   Press [CTRL+C] to stop.

"
echo "Creating border of size $(($HEIGHT)) x $(($WIDTH))"
initgrid
for i in "${!GRID[@]}"; do
   echo "key  : $i"
   echo "value: ${GRID[$i]}"
done
echo "Beginning simulation . . ."
drawborder
drawcells

sleep 10



while :; do
   sleep 0.3
   # for i in "${!GRID[@]}"; do
   #    echo "key  : $i"
   #    echo "value: ${GRID[$i]}"
   # done
   # for c in "${!GRID[@]}"; do
   #    LASTGRID[$c]=${GRID[$c]}
   # done
   drawcells
done