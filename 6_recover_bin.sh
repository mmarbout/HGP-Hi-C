#!/bin/bash
# Martial Marbouty
# RSG - Meta3C TEAM

# this script will generate data based on the louvain partitionning procedure

#usage --> bash louvain_data_treatment.sh NAME_project targeted_iterations(Integer)

################# input ###################

project=$1
iterations=$2
targeted_iteration=$3
threshold=$4
assembly=$5

mkdir -p "$project"/fasta_it"$targeted_iteration"_over"$threshold"/

cat "$project"/binning/louvain_mat_weighted_"$targeted_iteration".txt | awk -v var3=$threshold '$3 >= var3 {print $1,$2,"1"}' | sort -u > "$project"/temp/overlapping_comm.txt
python secondary_scripts/connected.py "$project"/temp/overlapping_comm.txt "$project"/temp/connected_"$threshold".txt
cat "$project"/temp/connected_"$threshold".txt | sed '1d' > "$project"/temp/data_connect.txt
cat -n "$project"/temp/data_connect.txt | awk '{print "bin",$1,"overcomm",$2}' > "$project"/temp/data_overcomm_it"$targeted_iteration"_over"$threshold".txt

#var=$(cat "$project"/temp/data_overcomm_it"$targeted_iteration"_over"$threshold".txt | awk '{print $4}' | sort -u)

rm "$project"/binning/data_overcomm_it"$targeted_iteration"_over"$threshold".txt

#for over in $var
for over in $(seq 1 100)
do 

cat "$project"/temp/data_overcomm_it"$targeted_iteration"_over"$threshold".txt | awk '$4=="'$over'" {print $2}' > "$project"/temp/temp_bin.txt

var2=$(cat "$project"/temp/temp_bin.txt)

rm "$project"/temp/overcomm_data.txt
rm "$project"/temp/overcomm_data_V2.txt
rm "$project"/temp/overcomm_data_V3.txt

for bin in $var2 
do

cat "$project"/binning/bin_data_"$targeted_iteration".txt | awk '$1=="'$bin'" {print $0,"overlapping","'$over'"}' >> "$project"/temp/overcomm_data.txt
cat "$project"/binning/contig_data_"$targeted_iteration".txt | awk '$5=="'$bin'" {print $0,"overlapping","'$over'"}' >> "$project"/temp/overcomm_data_V2.txt
cat "$project"/binning/contig_data_"$targeted_iteration".txt | awk '$5=="'$bin'" {print "NODE_"$1"_length_"$2}' >> "$project"/temp/overcomm_data_V3.txt

done

size_overcomm=$(cat "$project"/temp/overcomm_data.txt | awk '{sum+=$3} END {print sum}')
contigs_overcomm=$(cat "$project"/temp/overcomm_data.txt | awk '{sum+=$2} END {print sum}')

cat "$project"/temp/overcomm_data.txt | awk '{print $0,"'$contigs_overcomm'","'$size_overcomm'"}' >> "$project"/binning/data_overcomm_it"$targeted_iteration"_over"$threshold".txt
cat "$project"/temp/overcomm_data_V2.txt | awk '{print $0,"'$contigs_overcomm'","'$size_overcomm'"}' >> "$project"/binning/data_overcomm_it"$targeted_iteration"_over"$threshold"_contig.txt
python secondary_scripts/extract_contig.py "$assembly" "$project"/temp/overcomm_data_V3.txt "$project"/fasta_it"$targeted_iteration"_over"$threshold"/over"$over".fa

done


#var=$(cat "$project"/binning/data_overcomm_it"$targeted_iteration"_over"$threshold".txt | awk '{print $4}' | sort -u)

#for over in $var
#do 

#cat "$project"/binning/data_overcomm_it"$targeted_iteration"_over"$threshold".txt | awk '$4=="'$over'" {print $2}' > "$project"/temp/temp.core.txt
#python extract_contig.py "$assembly" "$project"/temp/temp.core.txt "$project"/fasta_it"$targeted_iteration"_over"$threshold"/over"$over".fa

#done
