#!/bin/bash
# Martial Marbouty
# RSG - Meta3C TEAM

# this script will generate data based on the louvain partitionning procedure

#usage --> bash louvain_data_treatment.sh NAME_project targeted_iterations(Integer)

################# input ###################
#project name
project=$1

#files containing the targeted bins
targeted_bin=$2

#louvain (number of iterations for the recursive process)
iterations=$3

#louvain level
targeted_iteration=$4

#overlappingthreshold
threshold=$5

#PATH to the initial network file
network=$6

#PATH to the assembly
assembly=$7


echo "cleaning previous files versions"
rm temp/*
rm "$project"/temp/*
echo ""

mkdir -p "$project"/fasta_recursive/
mkdir -p "$project"/subnetwork/
mkdir -p "$project"/binning_recur/

cat "$network" | sort -k 1,1 > temp/network_sorted.txt
cat data_contigs/idx_contig_length_cov_GC_"$project".txt | awk '{print $1,$3,$4,$5}' | sort -k 1,1 > "$project"/temp/contig_data.txt

var=$(cat "$targeted_bin")

for bin in $var
do 

	echo "bin in progress:""$bin"
	echo "1 - extracting subnetwork"

	cat "$project"/binning/data_overcomm_it"$targeted_iteration"_over"$threshold"_contig.txt | awk '$9=="'$bin'" {print $1}' | sort > temp/temp1.txt
	join -11 -21 temp/temp1.txt temp/network_sorted.txt | sort -k 2,2 > temp/temp3.txt
	join -11 -22 temp/temp1.txt temp/temp3.txt > "$project"/subnetwork/network_"$bin".txt

	echo "subnetwork generated"
	echo ""
	echo "2 - performing louvain recursive procedure"
	echo "number of iterations:""$iterations"

#conversion du réseau en fichier binaire
	louvain/convert_net -i "$project"/subnetwork/network_"$bin".txt -o "$project"/binning_recur/net_"$bin".bin -w "$project"/binning_recur/net_"$bin".weights 

# loop des itérations de Louvain
	for iteration in $(seq 1 "$iterations")

	do
		echo "iteration in progress: iteration n°""$iteration"

		louvain/louvain "$project"/binning_recur/net_"$bin".bin -l -1 -w "$project"/binning_recur/net_"$bin".weights > "$project"/binning_recur/net_"$bin".tree
		louvain/hierarchy "$project"/binning_recur/net_"$bin".tree > "$project"/binning_recur/level_louvain_"$bin".txt 
		level=$(tail -1 "$project"/binning_recur/level_louvain_"$bin".txt | awk '{print $2}')
		louvain/hierarchy "$project"/binning_recur/net_"$bin".tree -l "$level" > "$project"/temp/output_louvain_"$iteration".txt
		cat "$project"/temp/output_louvain_"$iteration".txt | awk '{print $1}' > "$project"/temp/contig_idx.txt
		cat "$project"/temp/output_louvain_"$iteration".txt | awk '{print $2";"}' > "$project"/temp/bin_idx_"$iteration".txt

	done
	echo "louvain iterative process finished"
	echo ""
	echo "3 - compiling data"

	paste "$project"/temp/bin_idx_* | sed 's/\t//g' > "$project"/temp/temp1.txt
	paste "$project"/temp/contig_idx.txt "$project"/temp/temp1.txt | awk '{print $1,$2}' > "$project"/binning_recur/output_louvain_"$iterations"it_"$bin".txt

	echo "generating contig and bin data after louvain partitionning"

	cat "$project"/binning_recur/output_louvain_"$iterations"it_"$bin".txt | awk '{print $1}' > "$project"/temp/index_community.txt
	cat "$project"/binning_recur/output_louvain_"$iterations"it_"$bin".txt | awk '{print $2}' | awk -F ";" -v f=1 -v t="$iterations" '{for(i=f;i<=t;i++) printf("%s%s%s",$i,";",(i==t)?"\n":OFS)}' | sed 's/; /;/g' > "$project"/temp/contig_community.txt
	paste "$project"/temp/index_community.txt "$project"/temp/contig_community.txt | sort -k 2b,2 > "$project"/temp/contig_community_"$iterations".txt

	cat "$project"/temp/contig_community_"$iterations".txt | awk '{print $2}' | sort | uniq -c | sort -k 1,1 -g -r > "$project"/temp/tmp.txt

	cat -n "$project"/temp/tmp.txt | awk '{print "bin",$1,"size",$2,"index",$3}' > "$project"/binning_recur/bin_"$iterations"_"$bin".txt

	cat "$project"/binning_recur/bin_"$iterations"_"$bin".txt | awk '{print $2,$4,$6}' | sort -k 3b,3 > "$project"/temp/bin_trie.temp

	join -12 -23 "$project"/temp/contig_community_"$iterations".txt "$project"/temp/bin_trie.temp | awk '{print $2,$3,$4}' | sort -k 1b,1 > "$project"/temp/contig_bin_"$iterations".txt

	join -11 -21 "$project"/temp/contig_data.txt "$project"/temp/contig_bin_"$iterations".txt | sort -k 5,5 > "$project"/temp/contig_data_"$iterations".txt

	var3=$(cat "$project"/temp/contig_bin_"$iterations".txt | awk '$3 > 1 {print $2}' | sort -u)

	rm "$project"/temp/bin_data2.txt
	rm "$project"/temp/all_bin_data.txt

	for bins in $var3
	do

		cat "$project"/temp/contig_data_"$iterations".txt | awk '$5=="'$bins'" {print $0}' > "$project"/temp/bin_data.txt
		cat "$project"/temp/contig_data_"$iterations".txt | awk '$5=="'$bins'" {print $5,$6}' | head | sort -u >> "$project"/temp/bin_data2.txt
		cat "$project"/temp/bin_data.txt | awk '{sum+=$2} END {print sum}' >> "$project"/temp/all_bin_data.txt

	done

	paste "$project"/temp/bin_data2.txt "$project"/temp/all_bin_data.txt | sort -k 1,1 > "$project"/binning_recur/bin_data_"$iterations"_"$bin".txt
	join -15 -21 "$project"/temp/contig_data_"$iterations".txt "$project"/binning_recur/bin_data_"$iterations"_"$bin".txt | awk '{print $2,$3,$4,$5,$1,$6,$8}' > "$project"/binning_recur/contig_data_"$iterations"_"$bin".txt

	var4=$(cat "$project"/binning_recur/bin_data_"$iterations"_"$bin".txt | awk '$3>=500000 {print $1}' | sort -u)

	for subbin in $var4 
	do
		cat "$project"/binning_recur/contig_data_"$iterations"_"$bin".txt | awk '$5=="'$subbin'" {print "NODE_"$1"_length_"$2}' > "$project"/temp/bin_data_V3.txt
		python secondary_scripts/extract_contig.py "$assembly" "$project"/temp/bin_data_V3.txt "$project"/fasta_recursive/"$bin"_"$subbin".fa
	done
done









