#!/bin/bash
#Jude Rajasekera 3/20/17

tmpShelfmc=$HOME/ShelfMC/git_shelfmc #location of Shelfmc
runName=e18_ParamSpaceScan #name of run




cd $tmpShelfmc #move to home directory




AttenMin=500                      # MINIMUM attenuation length for the simulation
AttenMax=1000                     # MAXIMUM attenuation length
AttenInc=100                      # INCREMENT for attenuation length

RadiusMin=3                       # MINIMUM radius
RadiusMax=31                      # MAXIMUM radius
RadiusInc=7                       # INCREMENT

IceMin=500                        # etc...
IceMax=2900
IceInc=400

FirnMin=60
FirnMax=140
FirnInc=20

StDepthMin=0
StDepthMax=200
StDepthInc=50


if [ ! -f ./jobList.txt ]; then #see if there is an existing job file
    echo "Creating new job List"
    for ((L=$AttenMin;L<=$AttenMax;L+=$AttenInc)) #Attenuation length
    do
	for ((AR=$RadiusMin;AR<=$RadiusMax;AR+=$RadiusInc)) #Station radius (measured from center of radius to antenna
	do
            for ((T=$IceMin;T<=$IceMax;T+=$IceInc)) #Ice thickness
            do
		for ((FT=$FirnMin;FT<=$FirnMax;FT+=$FirnInc)) #Firn thickness
		do
                    for ((SD=$StDepthMin;SD<=$StDepthMax;SD+=$StDepthInc)) #Station depth
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
    runningJobs=$(showq | grep "cond0092" | wc -l) #change username here
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
