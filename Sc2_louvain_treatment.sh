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

echo "cleaning previous fasta files"
rm output/"$project"/fasta_"$targeted_iteration"/*.fa

#Fasta generation

echo "generating fasta files" 

cat output/"$project"/partition/contig_data_"$targeted_iteration".txt | awk '{print "NODE_"$1"_length_"$2"_cov_0",$1,$2,$3,$4,$5,$6,$7}' > output/"$project"/data_core_"$targeted_iteration"/data_iter_"$targeted_iteration".txt

#cat output/"$project"/partition/contig_data_"$targeted_iteration".txt | awk '{print "k141_"$1,$1,$2,$3,$4,$5,$6,$7}' > output/"$project"/data_core_"$targeted_iteration"/data_iter_"$targeted_iteration".txt

var=$(cat output/"$project"/partition/core_data_"$targeted_iteration".txt | awk '{print $1}')

for core in $var
do
echo "core in progress:""$core"
cat output/"$project"/data_core_"$targeted_iteration"/data_iter_"$targeted_iteration".txt | awk '$6=="'$core'" {print $0}' > output/"$project"/data_core_"$targeted_iteration"/data_"$core".txt
cat output/"$project"/data_core_"$targeted_iteration"/data_iter_"$targeted_iteration".txt | awk '$6=="'$core'" {print $1}' > temp/node.temp

var2=$(cat temp/node.temp)
for node in $var2
do
cat "$contigs"/"$node".fa >> output/"$project"/fasta_"$targeted_iteration"/"$core".fa
done

done

echo "FASTA Generated !!!!"
echo ""

echo "FINITO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

