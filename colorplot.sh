#!/bin/bash
#04/18/2017
#script will collect root files and plot as dictated by user
#Hannah Hasan

shelfmc=$HOME/ShelfMC/git_shelfmc ##set to your ShelfMC directory - should have the parameter space scan directory and a directory called "outputs". outputs may be empty

line1='{'
line2='  TFile *f = new TFile("'"Veff_${xvar}_${yvar}.root"'");' ##set later
line3='  TTree *SimParam = (TTree*)f->Get("sim_parameters");'
line4='  TCanvas *c = new TCanvas("c", "V_{eff}", 2000, 1000);'
line5='  TPad* p = new TPad("p","p",0.0,0.0,1.0,1.0);'
line6='  p->Draw();'
line7='  p->SetLeftMargin(0.15);'
line8='  p->SetRightMargin(0.15);'
line9='  p->cd();'
line10='  TH2F *h = new TH2F("''h''", "''V_{eff} vs '"$var1"' vs '"$var2"'"'",$xbins,$xmin,$xmax"', '"$ybins,$ymin,$ymax);" ##set later
line11='  double x;'
line12='  double y;'
line13='  double z;'
line14='  double veff=0;'
line15='  double energy;'
line16="  double avgs[$SIZE];" ##set later; SIZE varies depending on which variables we are plotting
line17='  SimParam->SetBranchAddress("'"$xbranch"'", &x );' ##set later
line18='  SimParam->SetBranchAddress("'"$ybranch"'", &y );' ##set later
line19='  SimParam->SetBranchAddress("Veff", &z);'
line20='  int v=0;'
line21="  for(int k=1; k<=$SIZE; k++){" ##set later for SIZE
line22='    veff = 0;'
line23='    for(v; v<(k*20.0); v++){'
line24='      SimParam->GetEntry(v);'
line25='      veff += z;'
line26='    }'
line27='    avgs[(k-1)] = (veff/20.0);'
line28='  }'
line29="  for(int i=0; i<$SIZE; i++){" ##set later for SIZE
line30='    SimParam->GetEntry((i*20));'
line31='    h->Fill(x,y,avgs[i]);'
line32='  }'
line33='  gStyle->SetPalette(1,0);'
line34='  h->GetXaxis()->SetTitle("'"$var1"' (m)");' ##set later
line35='  h->GetYaxis()->SetTitle("'"$var2"' (m)");' ##set later
line36='  h->GetZaxis()->SetTitle("V_{eff} (km^{3} str)");'
line37='  h->GetXaxis()->SetTitleOffset(1.2);'
line38='  h->GetYaxis()->SetTitleOffset(1.0);'
line39='  h->GetZaxis()->SetTitleOffset(1.3);'
line40='  gStyle->SetOptStat(0);'
line41='  h->Draw("COLZ");'
line42='  double const1;'
line43='  double const2;'
line44='  double const3;'
line45='  SimParam->SetBranchAddress("'"$const1br"'", &const1);' ##set later
line46='  SimParam->SetBranchAddress("'"$const2br"'", &const2);' ##set later
line47='  SimParam->SetBranchAddress("'"$const3br"'", &const3);' ##set later
line48='  SimParam->SetBranchAddress("exponent", &energy);'
line49='  SimParam->GetEntry(0);'
line50='  char const_1[30];'
line51='  char const_2[30];'
line52='  char const_3[30];'
line53='  char enrgy[30];'
line54='  sprintf(enrgy, "Energy (exponent): %d", energy);'
line55='  sprintf(const_1, "'"$const1br"' %d m", const1);' ##
line56='  sprintf(const_2, "'"$const2br"' %d m", const2);' ##
line57='  sprintf(const_3, "'"$const3br"' %d m", const3);' ## set later
line58='  TPaveText *t = new TPaveText(0,0,0.07,0.3,"brNDC");'
line59='  t->SetLabel("Simulation Parameters:");'
line60='  t->AddText(enrgy);'
line61='  t->AddText(const_1);'
line62='  t->AddText(const_2);'
line63='  t->AddText(const_3);'
line64='  t->Draw();'
line65='  c->Modified();'
line66='  c->Update();'
line67='  c->SaveAs("'"Veff_${xvar}_${yvar}.pdf"'");' ##set later
line68='}'


echo
echo
echo 'This script will allow you to choose two variables to plot effective volume against.'
echo
echo 'Enter the name of the run you wish to plot data for.'
## echo '***IMPORTANT*** please ensure there is no existing directory of this name in the "outputs" directory!'
echo
read -p 'Name of run: ' runName
echo
echo 'Thank you!'
echo
echo 'Please make your selections from the following list:'
echo '(A) - Attenuation Length'
echo '(R) - Antenna Radius'
echo '(I) - Ice Thickness'
echo '(F) - Firn Thickness'
echo '(S) - Station Depth'
echo
echo '** please use capital letters in your selection **'
echo
read -p 'Select the variable you wish to plot along the X-axis: ' xvar
read -p 'Now select the variable you wish to plot along the Y-axis: ' yvar
echo


cd $shelfmc/outputs
mkdir ${runName}_${xvar}_${yvar}

cd $shelfmc/$runName

attenprompt='Select what value at which to hold constant Attenuation Length'
atteninc=' > Choose only values between 500-1000, at increments of 100: '

radiusprompt='Select what value at which to hold constant Antenna Radius'
radiusinc=' > Choose only values between 3-31, at increments of 7: '

iceprompt='Select what value at which to hold constant Ice Thickness'
iceinc=' > Choose only values between 500-2900, at increments of 400: '

firnprompt='Select what value at which to hold constant Firn Thickness'
firninc=' > Choose only values between 60-140, at increments of 20: '

stprompt='Select what value at which to hold constant Station Depth'
stinc=' > Choose only values between 0-200, at increments of 50: '

if ([ "$xvar" = "A" ] && [ "$yvar" = "R" ]) || ([ "$yvar" = "A" ] && [ "$xvar" = "R" ]); then
    echo $iceprompt
    echo $iceinc
    read const1
    const1br='icethick'
    echo $firnprompt
    echo $firninc
    read const2
    const2br='firndepth'
    echo $stprompt
    echo $stinc
    read const3
    const3br='station_depth'
    echo
    echo 'Adding files...'
    echo
    for L in {500..1000..100}
    do
	cd Atten_Up$L
	for AR in {3..31..7}
	do
	    cd AntennaRadius$AR/IceThick$const1/FirnThick$const2/StationDepth$const3
            cp *.root $shelfmc/outputs/${runName}_${xvar}_${yvar}/Result_${L}_${AR}.root
	    cd ../../../../
	done
	cd ..
    done

elif ([ "$xvar" = "A" ] && [ "$yvar" = "I" ]) || ([ "$yvar" = "A" ] && [ "$xvar" = "I" ]); then
    echo $radiusprompt
    echo $radiusinc
    read const1
    const1br='st4_r'
    echo $firnprompt
    echo $firninc
    read const2
    const2br='firndepth'
    echo $stprompt
    echo $stinc
    read const3
    const3br='station_depth'
    echo
    for L in {500..1000..100}
    do
        cd Atten_Up$L/AntennaRadius$const1
        for Ice in {500..2900..400}
        do
            cd IceThick$Ice/FirnThick$const2/StationDepth$const3
            cp *.root $shelfmc/outputs/${runName}_${xvar}_${yvar}/Result_${L}_${Ice}.root
            cd ../../../
        done
        cd ../../
    done

elif ([ "$xvar" = "A" ] && [ "$yvar" = "F" ]) || ([ "$yvar" = "A" ] && [ "$xvar" = "F" ]); then
    echo $radiusprompt
    echo $radiusinc
    read const1
    const1br='st4_r'
    echo $iceprompt
    echo $iceinc
    read const2
    const2br='icethick'
    echo $stprompt
    echo $stinc
    read const3
    const3br='station_depth'
    echo
    for L in {500..1000..100}
    do
	cd Atten_Up$L/AntennaRadius$const1/Icethick$const2
	for FT in {60..140..20}
	do
	    cd FirnThick$FT/StationDepth$const3
	    cp *.root $shelfmc/outputs/${runName}_${xvar}_${yvar}/Result_${L}_${FT}.root
	    cd ../..
	done
	cd ../../..
    done

elif ([ "$xvar" = "A" ] && [ "$yvar" = "S" ]) || ([ "$yvar" = "A" ] && [ "$xvar" = "S" ]); then
    echo $radiusprompt
    echo $radiusinc
    read const1
    const1br='st4_r'
    echo $iceprompt
    echo $iceinc
    read const2
    const2br='icethick'
    echo $firnprompt
    echo $firninc
    read const3
    const3br='firndepth'
    echo
    for L in {500..1000..100}
    do
	cd Atten_Up$L/AntennaRadius$const1/IceThick$const2/FirnThick$const3
	for SD in {0..200..50}
	do
	    cd StationDepth$SD
	    cp *.root $shelfmc/outputs/${runName}_${xvar}_${yvar}/Result_${L}_${SD}.root
	    cd ../
	done
	cd ../../../..
    done

elif ([ "$xvar" = "R" ] && [ "$yvar" = "I" ]) || ([ "$yvar" = "R" ] && [ "$xvar" = "I" ]); then
    echo $attenprompt
    echo $atteninc
    read const1
    const1br='atten_up'
    echo $firnprompt
    echo $firninc
    read const2
    const2br='firndepth'
    echo $stprompt
    echo $stinc
    read const3
    const3br='station_depth'
    echo
    for AR in {3..31..7}
    do
	cd Atten_Up$const1/AntennaRadius$AR
	for Ice in {500..2900..400}
	do
	    cd IceThick$Ice/FirnThick$const2/StationDepth$const3
            cp *.root $shelfmc/outputs/${runName}_${xvar}_${yvar}/Result_${AR}_${Ice}.root
	    cd ../../..
	done
	cd ../..
    done

elif ([ "$xvar" = "R" ] && [ "$yvar" = "F" ]) || ([ "$yvar" = "R" ] && [ "$xvar" = "F" ]); then
    echo $attenprompt
    echo $atteninc
    read const1
    const1br='atten_up'
    echo $iceprompt
    echo $iceinc
    read const2
    const2br='icethick'
    echo $stprompt
    echo $stinc
    read const3
    const3br='station_depth'
    echo
    for AR in {3..31..7}
    do
	cd Atten_Up$const1/AntennaRadius$AR/IceThick$const2
	for FT in {60..140..20}
	do
	    cd FirnThick$FT/StationDepth$const3
            cp *.root $shelfmc/outputs/${runName}_${xvar}_${yvar}/Result_${AR}_${FT}.root
	    cd ../..
	done
	cd ../../..
    done

elif ([ "$xvar" = "R" ] && [ "$yvar" = "S" ]) || ([ "$yvar" = "R" ] && [ "$xvar" = "S" ]); then
    echo $attenprompt
    echo $atteninc
    read const1
    const1br='atten_up'
    echo $iceprompt
    echo $iceinc
    read const2
    const2br='icethick'
    echo $firnprompt
    echo $firninc
    read const3
    const3br='firndepth'
    echo
    for AR in {3..31..7}
    do
	cd Atten_Up$const1/AntennaRadius$AR/IceThick$const2/FirnThick$const3
	for SD in {0..200..50}
	do
	    cd StationDepth$SD
            cp *.root $shelfmc/outputs/${runName}_${xvar}_${yvar}/Result_${AR}_${SD}.root
	    cd ..
	done
	cd ../../../..
    done

elif ([ "$xvar" = "I" ] && [ "$yvar" = "F" ]) || ([ "$yvar" = "I" ] && [ "$xvar" = "F" ]); then
    echo $attenprompt
    echo $atteninc
    read const1
    const1br='atten_up'
    echo $radiusprompt
    echo $radiusinc
    read const2
    const2br='st4_r'
    echo $stprompt
    echo $stinc
    read const3
    const3br='station_depth'
    echo
    for Ice in {500..2900..400}
    do
	cd Atten_Up$const1/AntennaRadius$const2/IceThick$Ice
	for FT in {60..140..20}
	do
	    cd FirnThick$FT/StationDepth$const3
            cp *.root $shelfmc/outputs/${runName}_${xvar}_${yvar}/Result_${Ice}_${FT}.root
	    cd ../..
        done
	cd ../../..
    done

elif ([ "$xvar" = "I" ] && [ "$yvar" = "S" ]) || ([ "$yvar" = "I" ] && [ "$xvar" = "S" ]); then
    echo $attenprompt
    echo $atteninc
    read const1
    const1br='atten_up'
    echo $radiusprompt
    echo $radiusinc
    read const2
    const2br='st4_r'
    echo $firnprompt
    echo $firninc
    read const3
    const3br='firndepth'
    echo
    for Ice in {500..2900..400}
    do
	cd Atten_Up$const1/AntennaRadius$const2/IceThick$Ice/FirnThick$const3
	for SD in {0..200..50}
	do
	    cd StationDepth$SD
            cp *.root $shelfmc/outputs/${runName}_${xvar}_${yvar}/Result_${Ice}_${SD}.root
	    cd ..
        done
	cd ../../../..
    done

elif ([ "$xvar" = "F" ] && [ "$yvar" = "S" ]) || ([ "$yvar" = "F" ] && [ "$xvar" = "S" ]); then
    echo $attenprompt
    echo $atteninc
    read const1
    const1br='atten_up'
    echo $radiusprompt
    echo $radiusinc
    read const2
    const2br='st4_r'
    echo $iceprompt
    echo $iceinc
    read const3
    const3br='icethick'
    echo
    for FT in {60..140..20}
    do
	cd Atten_Up$const1/AntennaRadius$const2/IceThick$const3/FirnThick$FT
	for SD in {0..200..50}
	do
	    cd StationDepth$SD
            cp *.root $shelfmc/outputs/${runName}_${xvar}_${yvar}/Result_${FT}_${SD}.root
	    cd ..
        done
	cd ../../../..
    done
fi



if [ "$xvar" = "A" ]; then
    var1='Attenuation Length'
    xbins=6
    xmin=450
    xmax=1050
    xbranch='atten_up'
elif [ "$xvar" = "R" ]; then
    var1='Antenna Radius'
    xbins=5
    xmin='-0.5'
    xmax='34.5'
    xbranch='st4_r'
elif [ "$xvar" = "I" ]; then
    var1='Ice Thickness'
    xbins=7
    xmin=300
    xmax=3100
    xbranch='icethick'
elif [ "$xvar" = "F" ]; then
    var1='Firn Thickness'
    xbins=5
    xmin=50
    xmax=150
    xbranch='firndepth'
elif [ "$xvar" = "S" ]; then
    var1='Station Depth'
    xbins=5
    xmin='-25'
    xmax=225
    xbranch='station_depth'
fi


if [ "$yvar" = "A" ]; then
    var2='Attenuation Length'
    ybins=6
    ymin=450
    ymax=1050
    ybranch='atten_up'
elif [ "$yvar" = "R" ]; then
    var2='Antenna Radius'
    ybins=5
    ymin='-0.5'
    ymax='34.5'
    ybranch='st4_r'
elif [ "$yvar" = "I" ]; then
    var2='Ice Thickness'
    ybins=7
    ymin=300
    ymax=3100
    ybranch='icethick'
elif [ "$yvar" = "F" ]; then
    var2='Firn Thickness'
    ybins=5
    ymin=50
    ymax=150
    ybranch='firndepth'
elif [ "$yvar" = "S" ]; then
    var2='Station Depth'
    ybins=5
    ymin='-25'
    ymax=225
    ybranch='station_depth'
fi


let "SIZE=$xbins*$ybins"

####### all changing lines below:
line2='  TFile *f = new TFile("'"Veff_${xvar}_${yvar}.root"'");'
line10='  TH2F *h = new TH2F("h", "''V_{eff} vs '"$var1 vs $var2"'"'",$xbins,$xmin,$xmax"', '"$ybins,$ymin,$ymax);"
line16="  double avgs[$SIZE];"
line17='  SimParam->SetBranchAddress("'"$xbranch"'", &x );'
line18='  SimParam->SetBranchAddress("'"$ybranch"'", &y );'
line21="  for(int k=1; k<=$SIZE; k++){"
line29="  for(int i=0; i<$SIZE; i++){"
line34='  h->GetXaxis()->SetTitle("'"$var1"' (m)");'
line35='  h->GetYaxis()->SetTitle("'"$var2"' (m)");'
line45='  SimParam->SetBranchAddress("'"$const1br"'", &const1);'
line46='  SimParam->SetBranchAddress("'"$const2br"'", &const2);'
line47='  SimParam->SetBranchAddress("'"$const3br"'", &const3);'
line55='  sprintf(const_1, "'"$const1br"' %d m", const1);'
line56='  sprintf(const_2, "'"$const2br"' %d m", const2);'
line57='  sprintf(const_3, "'"$const3br"' %d m", const3);'
line67='c->SaveAs("'"Veff_${xvar}_${yvar}.pdf"'");'


cd $shelfmc/outputs/${runName}_${xvar}_${yvar}

hadd Veff_${xvar}_${yvar}.root *.root

for t in {1..68}; do
    lineName=line$t
    echo "${!lineName}" >> Veff_${xvar}_${yvar}.C
done

rm *Result*
root -l Veff_${xvar}_${yvar}.C

echo
echo
echo "Done!"
echo
echo