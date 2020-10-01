#!/bin/bash

# Simple RPG game for learning bash coding

# Generate a random number between 1 and the passed value, inclusive
random() {
	NUMBER=$[ ( $RANDOM % $1 )  + 1 ]
	echo $NUMBER
}

# Monster list. Calling this function chooses a monster at random and sets the corresponding variables
monster() {
	choice=`random $((level * 3))`
	if [[ $choice -eq 1 ]]; then
		monname="House cat"
		monhealth=4
		monattack=10
	fi
	if [[ $choice -eq 2 ]]; then
		monname="Rabbit"
		monhealth=17
		monattack=15
	fi
	if [[ $choice -eq 3 ]]; then
		monname="Giraffe"
		monhealth=70
		monattack=6
	fi
	if [[ $choice -eq 4 ]]; then
		monname="Rhino"
		monhealth=30
		monattack=8
	fi
	if [[ $choice -eq 5 ]]; then
		monname="Tiger"
		monhealth=65
		monattack=10
	fi
	if [[ $choice -eq 6 ]]; then
		monname="Bear"
		monhealth=80
		monattack=20
	fi
	if [[ $choice -eq 7 ]]; then
		monname="Dragon"
		monhealth=120
		monattack=30
	fi
	if [[ $choice -eq 8 ]]; then
		monname="Troll"
		monhealth=90
		monattack=10
	fi
	if [[ $choice -eq 9 ]]; then
		monname="Wizard"
		monhealth=50
		monattack=80
	fi
}

# Displays the current status of the game
status() {
	echo -e "\nStats: $name"
	echo "---------------------------------------------"
	echo -e "Level: $level\tExperience: $experience"
	echo -e "Health: $health\tAttack: $((attack * level))"
	echo "Kills: $kills"
	if [[ $healpotion -gt 0 ]]; then
		echo "Heal Potions: $healpotion"
	fi
}

# Set starting stats
health=100
attack=10
kills=0
level=1
experience=0
healpotion=1

clear
echo "Welcome to BASH RPG"
echo "What is your name?: "
read name

while [[ $health -gt 0 ]]; do
	monster
	status

        experiencegain=$(expr $monhealth + $monattack)
        experiencegain=$(expr $experiencegain / 3)
	# Fight or run phase

	echo -e "\n"
	echo -e "Battle"
	echo "---------------------------------------------"
	echo "You are faced with a $monname (Health: $monhealth, Attack: $monattack)"	
	echo "Do you wish to run or fight?: "
	read rof
	rof=$(echo "$rof" | tr '[:upper:]' '[:lower:]')
	if	[[ "$rof" = "fight" ]]; then
		echo -e "\nYou draw your weapon and face off against a $monname!" 
	else
		echo -e "\nYou sprint away and escape from a $monname!" 
		monhealth=0
	fi
	
	# Combat phase
	while [[ $health -gt 0 && $monhealth -gt 0 ]]; do
                currentattack=`random $((attack * level))`
		echo -e "\nYou attack for $currentattack damage."
		sleep 1
		((monhealth -= currentattack))

                currentmonattack=`random monattack`
		echo "$monname hits you for $currentmonattack damage."
		sleep 1
		((health -= $currentmonattack))
		if [[ $monhealth -lt 1 ]]; then
			echo -e "\nWin"
			echo "---------------------------------------------"
			echo -e "\nYou have defeated a $monname and gained $experiencegain experience points!"
			echo -e "Your health: $health"
			((kills += 1))
			((experience += experiencegain))

			if [ $experience -gt 50 ]; then
			  level=2
			fi

			if [ $experience -gt 150 ]; then
			  level=3
			fi

			# Heal Potion 
			pot=`random 4`
			if [[ $pot -eq 1 ]]; then
				echo -e "\nYou found a health potion!\n"
				((healpotion += 1))
			fi

			if [[ $healpotion -gt 0 ]]; then
				echo -e "\nHeal"
				echo "---------------------------------------------"
				echo -e "Do you want to drink a Health Potion? You have $healpotion."
				echo "Press 1 to drink or 2 to save"
				select drink in "Drink" "Save"; do
					case $drink in
						Drink ) 
							((health += 20))
							((healpotion -= 1))
						break;;
						Save ) 
							echo "You decide not to drink a health potion."
						break;;
					esac
				done
			fi
		fi

		# Death
		if [[ $health -lt 1 ]]; then
			echo -e "\nDefeated"
			echo "---------------------------------------------"
			echo -e "\nYou're dead. :("
			status
			echo -e "\nWould you like to play again?: "
			read again
			again=$(echo "$again" | tr '[:upper:]' '[:lower:]')
			if [[ $again = "yes" ]]; then
				health=100
				attack=10
				kills="0"
				monhealth=0
				experience=0
				level=1
				healpotion=1
			else
				echo "$kills - $name" >> .highscores
				cat .highscores | sort -n -r | tail -n 10 > .highscores.new
				mv .highscores.new .highscores; rm -f .highscores.new
				echo " -- HIGH SCORES -- "
				cat .highscores
				echo "GAME OVER!"
				exit
			fi
		fi
	done
done
