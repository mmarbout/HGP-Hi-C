#!/bin/bash
# Martial Marbouty
# RSG - Meta3C TEAM

# Script alginment = raw alignment data

# usage --> bash network.sh NAME_project Mapping_Quality_Threshold(Integer)


################# input ###################

project=$1
MQT=$2

################################################# CODE ###################################

mkdir -p "$project"/data_contigs/
mkdir -p "$project"/network/


#génération des données de couvertures
./jgi_summarize_bam_contig_depths --noIntraDepthVariance --minMapQual "$MQT" --minContigLength 500 --outputDepth "$project"/data_contigs/contigs_cov.txt "$project"/alignment/"$project"_for_sort.bam "$project"/alignment/"$project"_rev_sort.bam

# suite to do 

#génération des données GC pour chaque contig
perl calc.gc.pl -i "$project"/assembly/"$project"_500.fa -o "$project"/temp/GC_temp.txt
cat "$project"/temp/GC_temp.txt | sed '1d' | sort -k 1,1 > "$project"/data_contigs/contigs_GC.txt

#génération du fichier contenant les données des contigs
join -11 -21 temp/idx_temp.txt temp/temp1.txt > "$project"/data_contigs/idx_contig_length_cov_GC_"$project".txt

#génération du réseau brut
cat "$project"/alignement/"$project"_merge.sam | awk -v temp=$MQT '$4>=temp && $9>=temp {print $2,$7}' | sort | uniq -c | sed 's/_/ /g' | awk '{print $3,$9,$1}' | sort -k 1,1 > "$project"/network/"$project"_network_raw.txt

#génération du réseau normalisé
join -11 -22 "$project"/network/"$project"_network_raw.txt temp/idx_temp2.txt | sort -k 2,2 > temp/temp2.txt
join -12 -22 temp/temp2.txt temp/idx_temp2.txt | awk '$1!=$2 {print $1,$2,($3/(sqrt($7*$11)))}' > "$project"/network/"$project"_network_norm.txt

echo "network generated !!!!"

echo "cleaning"
rm temp/*.txt


