#!/bin/bash

# Any live cell with fewer than two live neighbours dies, as if by underpopulation.
# Any live cell with two or three live neighbours lives on to the next generation.
# Any live cell with more than three live neighbours dies, as if by overpopulation.
# Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

# OR (simplified)

# Any live cell with two or three neighbors survives.
# Any dead cell with three live neighbors becomes a live cell.
# All other live cells die in the next generation. Similarly, all other dead cells stay dead.

# Random returns a random number between 0 and 1.
random() {
   NUM=${RANDOM}/32767
   bc -l <<< "scale=2 ; $NUM"
}

# Initializes the grid for the game.
initgrid() {
   echo "Initializing grid . . ."
   for ((x=0;x<$WIDTH;x++)); do
      for ((y=0;y<$HEIGHT;y++)); do
         num=`random`
         key="${x},${y}"
         if (( $(echo "$num <= $SPAWNCHANCE" | bc -l) )); then # Took this from https://stackoverflow.com/questions/8654051/how-to-compare-two-floating-point-numbers-in-bash
            # echo "Spawning a cell for $key."
            GRID+=(1)
         else
            # echo "Creating an empty cell."
            GRID+=(0)
         fi
      done
   done
}

# Updates the cells in the grid for the next generation.
updategrid() {
   unset GRID
   ALIVECOUNT=0
   for ((x=0;x<$WIDTH;x++)); do
      for ((y=0;y<$HEIGHT;y++)); do
         key=$(( $x + $y + ( $x * ( $HEIGHT - 1 ) ) )) 
         alive=${LASTGRID[$key]}
         alivearoundcell=$(check $key)
         nextgen=0
         if [ $alive -eq 1 ]; then
            nextgen=1
            if [ $alivearoundcell -lt 2 ]; then
               nextgen=0
            fi
            if [ $alivearoundcell -gt 3 ]; then
               nextgen=0
            fi
         else
            if [ $alivearoundcell -eq 3 ]; then
               nextgen=1
            fi
         fi
         if [ $nextgen -eq 1 ]; then
            ((ALIVECOUNT++))
         fi
         GRID+=($nextgen)
      done
   done
   ((GENERATION++))
}

# Checks how many live neighbors are around
# 8 x 8                       8 x 4          3 x 3      4 x 4
#
# 0  8 16 24 32 40 48 56      0  8 16 24     0  3  6    0  4  8 12
# 1  9 17 25 33 41 49 57      1  9 17 25     1  4  7    1  5  9 13
# 2 10 18 26 34 42 50 58      2 10 18 26     2  5  8    2  6 10 14
# 3 11 19 27 35 43 51 59      3 11 19 27                3  7 11 15
# 4 12 20 28 36 44 52 60      4 12 20 28
# 5 13 21 29 37 45 53 61      5 13 21 29
# 6 14 22 30 38 46 54 62      6 14 22 30
# 7 15 23 31 39 47 55 63      7 15 23 31
#
# [-9, -1, +7]                [-9, -1, +7]  [-4, -1, +2] [-(h+1), -1, +(h-1)]
# [-8, +8]                    [-8, +8]      [-3, +3]     [-h, +h]
# [-7, +1, +9]                [-7, +1, +9]  [-2, +1, +4] [-(h-1), +1, +(h+1)]
check() {

   # Calculate the deltas
   d1=$(( (HEIGHT + 1) * -1 ))
   d2=-1
   d3=$((HEIGHT - 1))
   d4=$((HEIGHT * -1))
   d5=$HEIGHT
   d6=$(( (HEIGHT - 1) * -1 ))
   d7=1
   d8=$((HEIGHT + 1))
   # Find neighbors
   n1=$(($1 + $d1))
   n2=$(($1 + $d2))
   n3=$(($1 + $d3))
   n4=$(($1 + $d4))
   n5=$(($1 + $d5))
   n6=$(($1 + $d6))
   n7=$(($1 + $d7))
   n8=$(($1 + $d8))

   # Count the number of alive neighbors
   alive=0
   a1=$(isalive $n1)
   a2=$(isalive $n2)
   a3=$(isalive $n3)
   a4=$(isalive $n4)
   a5=$(isalive $n5)
   a6=$(isalive $n6)
   a7=$(isalive $n7)
   a8=$(isalive $n8)
   if [ $a1 -eq 1 ]; then
      ((alive++))
   fi
   if [ $a2 -eq 1 ]; then
      ((alive++))
   fi
   if [ $a3 -eq 1 ]; then
      ((alive++))
   fi
   if [ $a4 -eq 1 ]; then
      ((alive++))
   fi
   if [ $a5 -eq 1 ]; then
      ((alive++))
   fi
   if [ $a6 -eq 1 ]; then
      ((alive++))
   fi
   if [ $a7 -eq 1 ]; then
      ((alive++))
   fi
   if [ $a8 -eq 1 ]; then
      ((alive++))
   fi

   # declare -a neighbors=($n1 $n2 $n3 $n4 $n5 $n6 $n7 $n8)
   # echo "${#neighbors[@]}"
   # TEMPFILE=gol.tmp
   # echo 0 > $TEMPFILE
   # for i in $neighbors; do
   #    if [ $i -lt 0 ]; then
   #       continue
   #    fi
   #    if [ $i -gt $max ]; then
   #       continue
   #    fi
   #    cell=${LASTGRID[$i]}
   #    if [ $cell -eq 0 ]; then
   #       continue
   #    fi
   #    alive=$[$(cat $TEMPFILE) + 1]
   #    echo $alive
   #    echo $alive > $TEMPFILE
   # done
   # alive=$[$(cat $TEMPFILE) + 1]
   # unlink $TEMPFILE

   echo $alive
}

# Checks to see if a given cell is alive.
isalive() {
   max=$(($HEIGHT * $WIDTH - 1))
   if [ $1 -lt 0 ]; then
      echo 0
      return 
   fi
   if [ $1 -gt $max ]; then
      echo 0
      return
   fi
   key=$1
   cell=${LASTGRID[$key]}
   if [ $cell -eq 0 ]; then
      echo 0
      return
   fi
   echo 1
   return
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
   tput cup $(($LASTROW + $BUFFER + 1)) $FIRSTCOL
   x=$FIRSTCOL
   while [ $x -le $((LASTCOL + 1)) ];
   do
      printf "%b" "$WALL"
      x=$((x + 1));
   done

   printf "\n"

   tput sgr0 # Reset text attributes.
   tput cup 0 0
}

# Draws the cells for the game.
drawcells() {
   tput setab 3

   for ((x=0;x<$WIDTH;x++)); do
      for ((y=0;y<$HEIGHT;y++)); do
         key=$(( $x + $y + ( $x * ( $HEIGHT - 1 ) ) )) 
         alive=${GRID[$key]}
         tput cup $(($y + $FIRSTROW + $BUFFER + 1)) $(($x + $FIRSTCOL + 1))
         if [ $alive -eq 1 ]; then
            printf "%b" "$CELL"
         else
            tput setab 0
            printf "%b" "$CELL"
            tput setab 3
         fi
      done
   done

   tput sgr0 # Reset text attributes.
   tput cup 0 0
}

# Draws the generation information.
drawinfo() {
   tput cup $(($LASTROW + $BUFFER + 4)) $FIRSTCOL
   printf "%b" "Generation: $GENERATION"
   tput cup $(($LASTROW + $BUFFER + 5)) $FIRSTCOL
   printf "%b" "Alive: $ALIVECOUNT"
}

# Draws the start information.
drawstartinfo() {
   if [ $START -eq 0 ]; then
      tput setaf 2
      tput bold
      tput smul
      tput cup $(($BUFFER - 1)) 0 
      printf "%b" "Press Return to begin."
   else
      tput cup $(($BUFFER - 1)) 0
      printf "%b" "Simulating . . .      "
   fi

   tput sgr0 # Reset text attributes.
   tput cup 0 0
}
                        
WALL=" "
CELL=" "                                     

BUFFER=15   
ALIVECOUNT=0
GENERATION=1
START=0
FIRSTROW=3 
LASTROW=15
HEIGHT=$(($LASTROW - $FIRSTROW))                     
FIRSTCOL=3
LASTCOL=15 
WIDTH=$(($LASTCOL - $FIRSTCOL))
SPAWNCHANCE=0.25

declare -a LASTGRID
declare -a GRID

clear
echo -n "This is a simulation of the Conway's Game of Life:

   1. Any live cell with fewer than two live neighbours dies, as if by underpopulation.
   2. Any live cell with two or three live neighbours lives on to the next generation.
   3. Any live cell with more than three live neighbours dies, as if by overpopulation.
   4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

   Press [CTRL+C] to stop.

"
echo "Creating border of size $(($HEIGHT)) x $(($WIDTH))"
initgrid
echo "Setting up simulation . . ."
drawborder
drawinfo
drawcells
drawstartinfo
sleep 0.1
read
START=1
drawstartinfo

while :; do
   copy=${!GRID[*]}
   for i in $copy; do
      LASTGRID[$i]=${GRID[$i]}
   done

   updategrid
   drawinfo

   sleep 0.15

   if [ $ALIVECOUNT -eq 0 ]; then
      tput cup $(($LASTROW + $BUFFER + 7)) 0
      printf "%b" "All cells have died! Simulation over.\n"
      exit
   fi

   drawcells
done