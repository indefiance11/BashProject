#!/bin/bash 


#Cleanup last run
rm Dealers_working_with_winning_players


#Get all losses
grep -- -$* ./Player_Analysis/* | sed 's/_win_loss_player_data:/ / ; s/\./ / ; s/\// / ; s/Player_Analysis/ / ; s/\// /' > Roulette_Losses


#Only Want the Names
cat  Roulette_Losses | tr -s ' ' | tr -d '[0-9]' | sed 's/[^A-Za-z0-9_.;]/ /g' | sed 's/AM// ; s/PM//' > Roulette_Losses_Names


#Count the times for recurring losses under the same name
repeated_losses=$(grep -wo "[[:alnum:]]\+" ./Roulette_Losses_Names | sort | uniq -cd | sed 's/[^0-9]*//g' | head -n 1)


#if number of repeated losses greater than 5, then record first and last name of player
if [ $repeated_losses -gt 5 ]
then
	F_name_of_player=$(grep -wo "[[:alnum:]]\+" Roulette_Losses_Names | sort | uniq -cd | tr -d '[0-9]' | head -n 1) 
	L_name_of_player=$(grep -wo "[[:alnum:]]\+" Roulette_Losses_Names | sort | uniq -cd | tr -d '[0-9]' | tail -n 1)
	echo suspicious wins found, cross referencing player ${F_name_of_player} ${L_name_of_player} with dealer schedules
else 
	echo "no players winning more than 5 times"
	exit
fi

#search losses for dates and times of player winning more than 5 times
#echo ${F_name_of_player}
grep ${F_name_of_player}  Roulette_Losses > dates_and_times_of_winning_player
run_loops=$(cat dates_and_times_of_winning_player | wc -l)
lines_to_check=$run_loops

while [ $run_loops -ge 1 ]

do


 	head -n $lines_to_check dates_and_times_of_winning_player | tail -n 1 > date_time

	date_of_shift=$(cat date_time  | awk '{print $1}')

	dig_time=$(cat date_time | awk '{print $2}')

	am_pm=$(cat date_time | awk '{print $3}')


	cat ./Dealer_Analysis/"${date_of_shift}"_Dealer_schedule > dealer_sched 

	grep -w ${dig_time} dealer_sched > dealer_sched1

	grep -w ${am_pm} dealer_sched1  | awk '{print $1, $2, $5, $6}' >> Dealers_working_with_winning_players

	echo checked date ${date_of_shift} at this time $dig_time $am_pm	

	grep -w ${am_pm} dealer_sched1  | awk '{print $1, $2, $5, $6}'
	

	let "lines_to_check--"
	let "run_loops--"

done 

echo "Number of matching wins with dealer:"
cat Dealers_working_with_winning_players | wc -l

rm date_time
rm dealer_sched
rm dealer_sched1

