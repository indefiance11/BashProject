#!/bin/bash 

#declare -i date
#declare -i dig_time


#Get all losses
grep -- -$* ./Player_Analysis/* | sed 's/_win_loss_player_data:/ / ; s/\./ / ; s/\// / ; s/Player_Analysis/ / ; s/\// / ; s/:00:00//' > Roulette_Losses
cat Roulette_Losses | wc -l
#Only Want the Names
cat  Roulette_Losses | tr -s ' ' | tr -d '[0-9]' | sed 's/[^A-Za-z0-9_.;]/ /g' | sed 's/AM// ; s/PM//' > Roulette_Losses_Names


#Count the times for recurring losses to same top winning player
repeated_losses=$(grep -wo "[[:alnum:]]\+" ./Roulette_Losses_Names | sort | uniq -cd | sed 's/[^0-9]*//g' | head -n 1)


#if number of repeated losses greater than 5, then record first and last name of player
if [ $repeated_losses -gt 5 ]
then
	F_name_of_player=$(grep -wo "[[:alnum:]]\+" Roulette_Losses_Names | sort | uniq -cd | tr -d '[0-9]' | head -n 1) 
	L_name_of_player=$(grep -wo "[[:alnum:]]\+" Roulette_Losses_Names | sort | uniq -cd | tr -d '[0-9]' | tail -n 1)
	echo searching player ${F_name_of_player} ${L_name_of_player}
else 
	echo "no players winning more than 5 times"
	exit
fi

#search losses for dates and times of player winning more than 5 times
#echo ${F_name_of_player}
cat Roulette_Losses | grep ${F_name_of_player} > dates_and_times_of_winning_player
lines_to_check=$(cat dates_and_times_of_winning_player | wc -l)

while [ $lines_to_check -ge 1 ]

do
	date_of_shift=$(cat dates_and_times_of_winning_player |grep "${F_name_of_player}" | awk '{print $1}' | head -n "$lines_to_check" | tail -n 1)
	echo ${date_of_shift} >> Dealers_working_with_winning_players
	echo $lines_to_check	
	dig_time=$(cat dates_and_times_of_winning_player |grep "${F_name_of_player}" | awk '{print $2}' | head -n "$lines_to_check" | tail -n 1 )
	echo $dig_time >> Dealers_working_with_winning_players

	am_pm=$(cat dates_and_times_of_winning_player |grep "${F_name_of_player}" | awk '{print $3}' | head -n "$lines_to_check" | tail -n 1)
	#echo $am_pm

	cat ./Dealer_Analysis/"${date_of_shift}"_Dealer_schedule  | grep "${dig_time}" | grep "${am_pm}" | awk '{print $1, $2, $5, $6}' >> Dealers_working_with_winning_players
	#echo $date $dig_time $am_pm ;
	#echo $lines_to_check
	let "lines_to_check -= 1"

done


