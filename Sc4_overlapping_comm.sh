#!/usr/bin/env bash
# Meta3C team
# Martial Marbouty
# Lyam Baudry
# Théo Foutel-Rodier

############################################# PARAMETERS to be fill ######################################

#louvain level
targeted_iteration=$1

#project name
project=$2

#overlappingthreshold
threshold=$3

#network
network=$4

mkdir -p output/"$project"/overlapping_fasta"$threshold"/
mkdir -p output/"$project"/overlapping_data"$threshold"/
mkdir -p output/"$project"/subnetwork_overlapping"$threshold"/


cat "$network" | sort -k 1,1 > temp/network_sorted.txt

echo "cleaning previous files versions"
rm output/"$project"/overlapping_fasta"$threshold"/*.fa
rm output/"$project"/overlapping_data"$threshold"/*.txt
rm output/"$project"/subnetwork_overlapping"$threshold"/*.txt

cat output/"$project"/data_iter"$targeted_iteration"/louvain_mat_weighted.txt | awk -v var3=$threshold '$3 >= var3 {print $1,$2,"1"}' | sort -u > temp/overlapping_comm.txt
python scripts/connected.py temp/overlapping_comm.txt output/"$project"/data_iter"$targeted_iteration"/connected_"$threshold".txt
cat output/"$project"/data_iter"$targeted_iteration"/connected_"$threshold".txt | sed '1d' > temp/data_connect.txt
cat -n temp/data_connect.txt | awk '{print "core",$1,"overcomm",$2}' > output/"$project"/overlapping_data"$threshold"/data_overcomm.txt


var=$(cat output/"$project"/overlapping_data"$threshold"/data_overcomm.txt | awk '{print $4}' | sort -u)

for over in $var
do 

cat output/"$project"/overlapping_data"$threshold"/data_overcomm.txt | awk '$4=="'$over'" {print $2}' > temp/temp.core.txt

var2=$(cat temp/temp.core.txt)

rm temp/overcomm_data.txt

for core in $var2 
do

cat output/"$project"/fasta_"$targeted_iteration"/"$core".fa >> output/"$project"/overlapping_fasta"$threshold"/overlapping"$over".fa
cat output/"$project"/data_core_"$targeted_iteration"/data_"$core".txt | awk '{print $0,"overlapping","'$over'"}' >> temp/overcomm_data.txt

done

size_overcomm=$(cat temp/overcomm_data.txt | awk '{sum+=$3} END {print sum}')
contigs_overcomm=$(cat temp/overcomm_data.txt | wc -l | awk '{print $1}')

cat temp/overcomm_data.txt | awk '{print $0,"'$contigs_overcomm'","'$size_overcomm'"}' > output/"$project"/overlapping_data"$threshold"/overcomm_data_"$over".txt
done

var=$(cat output/"$project"/overlapping_data"$threshold"/data_overcomm.txt | awk '$4<= 100 {print $4}' | sort -u)

echo "creating subnetwork for first 100 overlapping communities"

for over in $var
do 

echo "creating subnetwork for firstoverlapping communities: ""$over"

cat output/"$project"/overlapping_data"$threshold"/overcomm_data_"$over".txt | awk '{print $2}' | sort > temp/temp1.txt
join -11 -21 temp/temp1.txt temp/network_sorted.txt | sort -k 2,2 > temp/temp3.txt
join -11 -22 temp/temp1.txt temp/temp3.txt > output/"$project"/subnetwork_overlapping"$threshold"/network_"$over".txt

echo "subnetwork generated"
echo ""

done
