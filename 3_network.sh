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
secondary_scripts/./jgi_summarize_bam_contig_depths --noIntraDepthVariance --minMapQual "$MQT" --minContigLength 500 --outputDepth "$project"/temp/cov_temp.txt "$project"/alignment/"$project"_for_sort.bam "$project"/alignment/"$project"_rev_sort.bam
cat "$project"/temp/cov_temp.txt | sed '1d' | awk '{print $1,$3}' | sort -k 1,1 > "$project"/data_contigs/contigs_cov.txt

#génération des données GC pour chaque contig
perl secondary_scripts/calc.gc.pl -i "$project"/assembly/"$project"_500.fa -o "$project"/temp/GC_temp.txt
cat "$project"/temp/GC_temp.txt | sed '1d' | sort -k 1,1 > "$project"/data_contigs/contigs_GC.txt

#génération du fichier contenant les données des contigs
join -11 -21 "$project"/data_contigs/contigs_cov.txt "$project"/data_contigs/contigs_GC.txt | sed 's/_/ /g' | awk '{print $2,$1"_"$2"_"$3"_"$4,$4,$5,$6}' | sort -k 1,1 > "$project"/data_contigs/idx_contig_length_cov_GC_"$project".txt

#génération du réseau brut
cat "$project"/alignment/"$project"_merge.sam | awk -v temp=$MQT '$4>=temp && $9>=temp {print $2,$7}' | sort | uniq -c | sed 's/_/ /g' | awk '{print $3,$7,$1}' | sort -k 1,1 > "$project"/network/"$project"_network.txt
cat "$project"/network/"$project"_network.txt | awk '$1!=$2 {print $1,$2,$3}' | sort -k 1,1 > "$project"/network/"$project"_network_raw.txt

#génération du réseau normalisé
join -11 -21 "$project"/network/"$project"_network_raw.txt "$project"/data_contigs/idx_contig_length_cov_GC_"$project".txt | sort -k 2,2 > "$project"/temp/temp2.txt
join -12 -21 "$project"/temp/temp2.txt "$project"/data_contigs/idx_contig_length_cov_GC_"$project".txt | awk '$1!=$2 {print $1,$2,($3/(sqrt($6*$10)))}' > "$project"/network/"$project"_network_norm.txt

echo "network generated !!!!"

echo "calculating network metrics"
echo "mapped PE reads with a quality above ""$MQT"
cat "$project"/network/"$project"_network.txt | awk '{sum+=$3} END {print sum}'
echo ""
echo "mapped PE reads with both extremities on different contigs"
cat "$project"/network/"$project"_network_raw.txt | awk '{sum+=$3} END {print sum}'
echo ""
echo "3D ratio"
all_PE=$(cat "$project"/network/"$project"_network.txt | awk '{sum+=$3} END {print sum}')
cat "$project"/network/"$project"_network_raw.txt | LC_NUMERIC="C" awk '{sum+=$3} END {print sum}' | awk '{print $1/"'$all_PE'"}'
echo ""


echo "cleaning"
rm "$project"/temp/*.txt


