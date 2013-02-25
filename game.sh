#!/bin/bash

random() {
	NUMBER=$[ ( $RANDOM % $1 )  + 1 ]
	echo $NUMBER
}

monster() {
	choice=`random 3`
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
}

status() {
	echo "Your name: $name"
	echo "Health: $health"
	echo "Attack: $attack"
	echo "Kills: $kills"
}

health=100
attack=10
kills="0"

echo "Welcome to Basher Inc"
echo -n "What is your name?: "
read name

while [[ $health -gt 0 ]]; do
	monster
	status
	echo "You are faced with a: $monname"	
	echo -n "Do you wish to run or fight?: "
	read rof
	rof=$(echo "$rof" | tr '[:upper:]' '[:lower:]')
	if	[[ "$rof" = "run" ]]; then
		echo "You sprint away and escape from $monname!" 
	fi

	if	[[ "$rof" = "fight" ]]; then
		echo "You draw your weapon and face off against $monname!" 
	else
		echo "You sprint away and escape from $monname!" 
	fi
	while [[ $health -gt 0 && $monhealth -gt 0 ]]; do
		echo "You attack for $attack damage."
		sleep 1
		monhealth=$(expr $monhealth - $attack)
		echo "$monname hits you for $monattack damage."
		sleep 1
		health=$(expr $health - $monattack)
		if [[ $monhealth -lt 1 ]]; then
			echo "You have defeated $monname!"
			kills=$(expr $kills + 1)
		fi
		if [[ $health -lt 1 ]]; then
			echo "You're dead. :("
		fi
	done
done
