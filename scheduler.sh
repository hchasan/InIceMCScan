#!/bin/bash
#Jude Rajasekera 3/20/17

tmpShelfmc=$HOME/ShelfMC/git_shelfmc #location of Shelfmc
runName=e18_ParamSpaceScan #name of run

cd $tmpShelfmc #move to home directory

if [ ! -f ./jobList.txt ]; then #see if there is an existing job file
    echo "Creating new job List"
    for L in {500..1000..100} #attenuation length 500-1000
    do
	for AR in {3..31..7} #Antenna spacing 3-31
	do
            for T in {500..2900..400} #Thickness of Ice 500-2900
            do
		for FT in {60..140..20} #Firn Thinckness 60-140
		do
                    for SD in {0..200..50} #Station Depth
                    do
		    echo "cd $runName/Atten_Up$L/AntennaRadius$AR/IceThick$T/FirnThick$FT/StationDepth$SD" >> jobList.txt
                    done
		done
            done
	done
    done
else 
    echo "Picking up from last job"
fi


numbLeft=$(wc -l < ./jobList.txt)
while [ $numbLeft -gt 0 ];
do
    jobs=$(showq | grep "cond0092") #change username here
    echo '__________Current Running Jobs__________'
    echo "$jobs"
    echo ''
    runningJobs=$(showq | grep "cond0092" | wc -l) #change unsername here
    echo Number of Running Jobs = $runningJobs 
    echo Number of jobs left = $numbLeft
    if [ $runningJobs -le 20 ];then
	line=$(head -n 1 jobList.txt)
	$line
	echo Submit Job && pwd
	qsub run_shelfmc_multithread.sh
	cd $tmpShelfmc
	sed -i 1d jobList.txt
    else
	echo "Full Capacity"
    fi
    sleep 1
    numbLeft=$(wc -l < ./jobList.txt)
done
