#!/usr/bin/env bash
# Meta3C team
# Martial Marbouty
# Lyam Baudry

############################################# READ ME ######################################

#                              this is the Third script of the Meta3C pipeline
#				Do not forget to fill the paramaters below
#				Launching this script implies that you have already performed the Script1 and Script 2

############################################# PARAMETERS to be fill ######################################

#louvain level
targeted_iteration=$1

#project name
project=$2

#network
network=$3

#repertory containing contigs in fasta
#contigs=/media/rsg/3C-data2/INRA/assembly/fasta_contig
contigs=$4

############################################# CODES ######################################################

mkdir -p output/"$project"/fasta_"$targeted_iteration"
mkdir -p output/"$project"/data_core_"$targeted_iteration"
mkdir -p output/"$project"/Figures_"$targeted_iteration"
mkdir -p output/"$project"/data_iter"$targeted_iteration"

###################################################################################################

#matrice de louvain

echo "creating louvain matrice"
echo ""

echo "removing previous files"
rm output/"$project"/data_iter"$targeted_iteration"/louvain_mat.txt
rm output/"$project"/data_iter"$targeted_iteration"/louvain_mat_weighted.txt

for iteration in $(seq 1 "$targeted_iteration")
do
echo "iteration:""$iteration"

cat output/"$project"/partition/core_"$targeted_iteration".txt | awk '$4>1 {print $2,$6}' | sed 's/;/ /g' | awk -v temp=$iteration '{print $1,$(temp+1)}' > temp/id.temp

var2=$(cat temp/id.temp | awk '{print $1}')

for core in $var2
do

#echo "core in progress:""$core"

cat temp/id.temp | awk '$1=="'$core'" {print $2}' > temp/id2.txt

var3=$(cat temp/id2.txt)

for idx in $var3
do

cat temp/id.temp | awk '$2=="'$idx'" {print "'$core'",$1}' >> output/"$project"/data_iter"$targeted_iteration"/louvain_mat.txt

done
done
done 

cat output/"$project"/data_iter"$targeted_iteration"/louvain_mat.txt | sort | uniq -c | awk '{print $2,$3,$1"\n"$3,$2,$1}' > output/"$project"/data_iter"$targeted_iteration"/louvain_mat_weighted.txt

echo "cleaning"
rm output/"$project"/data_iter"$targeted_iteration"/louvain_mat.txt



