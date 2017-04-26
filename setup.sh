#!/bin/bash
#PBS -l walltime=04:00:00
#PBS -l nodes=1:ppn=1,mem=4000mb
#PBS -N hannah_SetupJob
#PBS -j oe
#PBS -A PCON0003
#Jude Rajasekera 3/20/17
#directories
WorkDir=$TMPDIR   
tmpShelfmc=$HOME/ShelfMC/git_shelfmc #set your ShelfMC directory here



#controlled variables for run
runName='e18_ParamSpaceScan' #name of run
NNU=10000000 #NNU per run
seed=42 #starting seed for every run, each processor will recieve a different seed (42,43,44,45...)
NNU="$(($NNU / 20))" #calculating processors per node, change 20 to however many processors your cluster has per node
ppn=20 #number of processors per node on cluster
########################### input.txt file ####################################################
input1="#inputs for ARIANNA simulation, do not change order unless you change ReadInput()"
input2="$NNU #NNU, setting to 1 for unique neutrino"
input3="$seed      #seed Seed for Rand3"
input4="18.0    #EXPONENT, !should be exclusive with SPECTRUM"
input5="1000    #ATGap, m, distance between stations"
input6="4       #ST_TYPE, !restrict to 4 now!"
input7="4 #N_Ant_perST, not to be confused with ST_TYPE above"
input8="2 #N_Ant_Trigger, this is the minimum number of AT to trigger"
input9="30      #Z for ST_TYPE=2"
input10="$T   #ICETHICK, thickness of ice including firn, 575m at Moore's Bay"
input11="1       #FIRN, KD: ensure DEPTH_DEPENDENT is off if FIRN is 0"
input12="1.30    #NFIRN 1.30"
input13="$FT      #FIRNDEPTH in meters"
input14="1 #NROWS 12 initially, set to 3 for HEXAGONAL"
input15="1 #NCOLS 12 initially, set to 5 for HEXAGONAL"
input16="0       #SCATTER"
input17="1       #SCATTER_WIDTH,how many times wider after scattering"
input18="0       #SPECTRUM, use spectrum, ! was 1 initially!"
input19="0       #DIPOLE,  add a dipole to the station, useful for st_type=0 and 2"
input20="0       #CONST_ATTENLENGTH, use constant attenuation length if ==1"
input21="$L     #ATTEN_UP, this is the conjuction of the plot attenlength_up and attlength_down when setting REFLECT_RATE=0.5(3dB)"
input22="250     #ATTEN_DOWN, this is the average attenlength_down before Minna Bluff measurement(not used anymore except for CONST_ATTENLENGTH)"
input23="4 #NSIGMA, threshold of trigger"
input24="1      #ATTEN_FACTOR, change of the attenuation length"
input25="0.85    #REFLECT_RATE,power reflection rate at the ice bottom"
input26="0       #GZK, 1 means using GZK flux, 0 means E-2 flux"
input27="0       #FANFLUX, use fenfang's flux which only covers from 10^17 eV to 10^20 eV"
input28="0       #WIDESPECTRUM, use 10^16 eV to 10^21.5 eV as the energy spectrum, otherwise use 17-20"
input29="1       #SHADOWING"
input30="1       #DEPTH_DEPENDENT_N;0 means uniform firn, 1 means n_firn is a function of depth"
input31="0 #HEXAGONAL"
input32="1       #SIGNAL_FLUCT 1=add noise fluctuation to signal or 0=do not"
input33="4.0     #GAINV  gain dependency"
input34="1       #TAUREGENERATION if 1=tau regeneration effect, if 0=original"
input35="$AR     #ST4_R radius in meters between center of station and antenna"
input36="350     #TNOISE noise temperature in Kelvin"
input37="80      #FREQ_LOW low frequency of LPDA Response MHz #was 100"
input38="1000    #FREQ_HIGH high frequency of LPDA Response MHz"
input39="/users/PCON0003/cond0092/ShelfMC/git_shelfmc/GainFiles/LP_gain_manual.txt     #GAINFILENAME"
input40="$SD     #STATION_DEPTH"
#######################################################################################################

cd $TMPDIR   
mkdir $runName
cd $runName

initSeed=$seed
counter=0
for L in {500..1000..100} #attenuation length 500-1000
do
    mkdir Atten_Up$L
    cd Atten_Up$L

    for AR in {3..31..7} #Antenna spacing 3-31m
    do
        mkdir AntennaRadius$AR
        cd AntennaRadius$AR

        for T in {500..2900..400} #Thickness of Ice 500-2900
        do
            mkdir IceThick$T
            cd IceThick$T
            for FT in {60..140..20} #Firn Thinckness 60-140
            do
                mkdir FirnThick$FT
                cd FirnThick$FT
                for SD in {0..200..50} #Station Depth
                do
                    mkdir StationDepth$SD
                    cd StationDepth$SD
                    #####Do file operations###########################################
                    counter=$((counter+1))
                    echo "Counter = $counter ; L = $L ; AR = $AR ; T = $T ; FT = $FT ; SD = $SD " #print variables

                    #define changing lines
                    input21="$L     #ATTEN_UP, this is the conjuction of the plot attenlength_up and attlength_down when setting REFLECT_RATE=0.5(3dB)"
		    input35="$AR     #ST4_R radius in meters between center of station and antenna"
                    input10="$T   #ICETHICK, thickness of ice including firn, 575m at Moore's Bay"
                    input13="$FT      #FIRNDEPTH in meters"
                    input40="$SD       #STATION_DEPTH"
		    
		    for (( i=1; i<=$ppn;i++)) #make 20 setup files for 20 processors
                    do

                        mkdir Setup$i #make setup folder
                        cd Setup$i #go into setup folder
                        seed="$(($initSeed + $i -1))" #calculate seed for this iteration
                        input3="$seed      #seed Seed for Rand3"

                        for j in {1..40} #print all input.txt lines
                        do
                            lineName=input$j
                            echo "${!lineName}" >> input.txt
                        done
			
                        cd ..
                    done
		    
		    pwd=`pwd`
                    #create job file
		    echo '#!/bin/bash' >> run_shelfmc_multithread.sh
		    echo '#PBS -l nodes=1:ppn='$ppn >> run_shelfmc_multithread.sh
		    echo '#PBS -l walltime=00:10:00' >> run_shelfmc_multithread.sh #change walltime as necessary
		    echo '#PBS -N hannah_'$runName'_job' >> run_shelfmc_multithread.sh #change job name as necessary
		    echo '#PBS -j oe'  >> run_shelfmc_multithread.sh
		    echo '#PBS -A PCON0003' >> run_shelfmc_multithread.sh #change group if necessary
		    echo 'cd ' $tmpShelfmc >> run_shelfmc_multithread.sh
		    echo 'runName='$runName  >> run_shelfmc_multithread.sh
		    for (( i=1; i<=$ppn;i++))
		    do
			echo './shelfmc_stripped.exe $runName/'Atten_Up$L'/'AntennaRadius$AR'/'IceThick$T'/'FirnThick$FT'/'StationDepth$SD'/Setup'$i' _'$i'$runName &' >> run_shelfmc_multithread.sh
		    done
		   # echo './shelfmc_stripped.exe $runName/'Atten_Up$L'/'AntennaGap$ATGap'/'IceThick$T'/'FirnThick$FT'/'StationDepth$SD'/Setup1 _01$runName &' >> run_shelfmc_multithread.sh
		    echo 'wait' >> run_shelfmc_multithread.sh
		    echo 'cd $runName/'Atten_Up$L'/'AntennaRadius$AR'/'IceThick$T'/'FirnThick$FT'/'StationDepth$SD >> run_shelfmc_multithread.sh
		    echo 'for (( i=1; i<='$ppn';i++)) #20 iterations' >> run_shelfmc_multithread.sh
		    echo 'do' >> run_shelfmc_multithread.sh
		    echo '  cd Setup$i #cd into setup dir' >> run_shelfmc_multithread.sh
		    echo '  mv *.root ..' >> run_shelfmc_multithread.sh
		    echo '  cd ..' >> run_shelfmc_multithread.sh
		    echo 'done' >> run_shelfmc_multithread.sh
		    echo 'hadd Result_'$runName'.root *.root' >> run_shelfmc_multithread.sh
		    echo 'rm *ShelfMCTrees*' >> run_shelfmc_multithread.sh
		    echo 'rm -rf Setup*' >> run_shelfmc_multithread.sh

		    chmod u+x run_shelfmc_multithread.sh # make executable

                    ##################################################################
                    cd ..
                done
                cd ..
            done
            cd ..
        done
        cd ..
    done
    cd ..
done
cd 

mv $WorkDir/$runName $HOME
