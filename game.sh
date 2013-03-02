#!/bin/bash

# Bashgame for bash learning

#RNG
random() {
	NUMBER=$[ ( $RANDOM % $1 )  + 1 ]
	echo $NUMBER
}
# Monster list
monster() {
	choice=`random 5`
	if [[ $choice -eq 1 ]]; then
		monname="House cat"
		monhealth=4
		monattack=6
	fi
	if [[ $choice -eq 2 ]]; then
		monname="Tiger"
		monhealth=17
		monattack=19
	fi
	if [[ $choice -eq 3 ]]; then
		monname="Giraffe"
		monhealth=70
		monattack=4
	fi
	if [[ $choice -eq 4 ]]; then
		monname="Horse"
		monhealth=14
		monattack=8
	fi
	if [[ $choice -eq 5 ]]; then
		monname="Rabbit"
		monhealth=2
		monattack=3
	fi
}

status() {
	echo "Your name: $name"
	echo "Health: $health"
	echo "Attack: $attack"
	echo "Kills: $kills"
}
# Set starting stats
health=100
attack=10
kills="0"

echo "Welcome to Basher Inc"
echo -n "What is your name?: "
read name

while [[ $health -gt 0 ]]; do
	monster
	status

	# Fight or run phase
	echo "You are faced with a $monname"	
	echo -n "Do you wish to run or fight?: "
	read rof
	rof=$(echo "$rof" | tr '[:upper:]' '[:lower:]')
	if	[[ "$rof" = "fight" ]]; then
		echo "You draw your weapon and face off against a $monname!" 
	else
		echo "You sprint away and escape from a $monname!" 
		monhealth=0
	fi
	
	# Combat phase
	while [[ $health -gt 0 && $monhealth -gt 0 ]]; do
		echo "You attack for $attack damage."
		sleep 1
		monhealth=$(expr $monhealth - $attack)
		echo "$monname hits you for $monattack damage."
		sleep 1
		health=$(expr $health - $monattack)
		if [[ $monhealth -lt 1 ]]; then
			echo "You have defeated a $monname! You have become more powerful!"
			kills=$(expr $kills + 1)
			attack=$(expr $attack + 1)
			# Heal Potion 
			pot=`random 6`
			if [[ $pot -eq 1 ]]; then
				echo "A health potion worth 20 HP drops, would you like to drink it?:"
				read drink
				drink=$(echo "$drink" | tr '[:upper:]' '[:lower:]')
				if [[ "$drink" = "yes" ]]; then
					health=$(expr $health + 20)
				fi	
			fi
		fi
		# Death
		if [[ $health -lt 1 ]]; then
			echo "You're dead. :("
			status
			echo -n "Would you like to play again?: "
			read again
			again=$(echo "$again" | tr '[:upper:]' '[:lower:]')
			if [[ $again = "yes" ]]; then
				health=100
				attack=10
				kills="0"
				monhealth=0
			else
				echo "$kills - $name" >> .highscores
				cat .highscores | sort -r | tail -n 10 > .highscores.new
				mv .highscores.new .highscores; rm -f .highscores.new
				echo " -- HIGH SCORES -- "
				cat .highscores
				echo "GAME OVER!"
				exit
			fi
		fi
	done
done
