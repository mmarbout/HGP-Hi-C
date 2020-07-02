#!/bin/bash
# Martial Marbouty
# RSG - Meta3C TEAM

# this script will generate data based on the louvain partitionning procedure

#usage --> bash louvain_data_treatment.sh NAME_project targeted_iterations(Integer)

################# input ###################

project=$1
iterations=$2
targeted_iteration=$3

############################################# CODE ######################################

echo "generating contig and bin data after louvain partitionning"

cat "$project"/binning/output_louvain_"$iterations"it.txt | awk '{print $1}' > "$project"/temp/index_community.txt
cat "$project"/binning/output_louvain_"$iterations"it.txt | awk '{print $2}' | awk -F ";" -v f=1 -v t="$targeted_iteration" '{for(i=f;i<=t;i++) printf("%s%s%s",$i,";",(i==t)?"\n":OFS)}' | sed 's/; /;/g' > "$project"/temp/contig_community.txt
paste "$project"/temp/index_community.txt "$project"/temp/contig_community.txt | sort -k 2b,2 > "$project"/temp/contig_community_"$targeted_iteration".txt

cat "$project"/temp/contig_community_"$targeted_iteration".txt | awk '{print $2}' | sort | uniq -c | sort -k 1,1 -g -r > "$project"/temp/tmp.txt
cat -n "$project"/temp/tmp.txt | awk '{print "bin",$1,"size",$2,"index",$3}' > "$project"/binning/bin_"$targeted_iteration".txt

cat "$project"/binning/bin_"$targeted_iteration".txt | awk '{print $2,$4,$6}' | sort -k 3b,3 > "$project"/temp/bin_trie.temp

join -12 -23 "$project"/temp/contig_community_"$targeted_iteration".txt "$project"/temp/bin_trie.temp | awk '{print $2,$3,$4}' | sort -k 1b,1 > "$project"/temp/contig_bin_"$targeted_iteration".txt

cat data_contigs/idx_contig_length_cov_GC_"$project".txt | awk '{print $1,$3,$4,$5}' | sort -k 1,1 > "$project"/temp/contig_data.txt

join -11 -21 "$project"/temp/contig_data.txt "$project"/temp/contig_bin_"$targeted_iteration".txt | sort -k 5,5 > "$project"/temp/contig_data_"$targeted_iteration".txt

var3=$(cat "$project"/temp/contig_bin_"$targeted_iteration".txt | awk '$3 > 1 {print $2}' | sort -u)

rm "$project"/temp/bin_data2.txt
rm "$project"/temp/all_bin_data.txt

for bin in $var3
do

cat "$project"/temp/contig_data_"$targeted_iteration".txt | awk '$5=="'$bin'" {print $0}' > "$project"/temp/bin_data.txt
cat "$project"/temp/contig_data_"$targeted_iteration".txt | awk '$5=="'$bin'" {print $5,$6}' | head | sort -u >> "$project"/temp/bin_data2.txt
cat "$project"/temp/bin_data.txt | awk '{sum+=$2} END {print sum}' >> "$project"/temp/all_bin_data.txt

done

paste "$project"/temp/bin_data2.txt "$project"/temp/all_bin_data.txt | sort -k 1,1 > "$project"/binning/bin_data_"$targeted_iteration".txt
join -15 -21 "$project"/temp/contig_data_"$targeted_iteration".txt "$project"/binning/bin_data_"$targeted_iteration".txt | awk '{print $2,$3,$4,$5,$1,$6,$8}' > "$project"/binning/contig_data_"$targeted_iteration".txt


echo "data generated !!!"

echo "creating louvain matrice"
echo ""

echo "removing previous files"
rm "$project"/temp/louvain_mat.txt


for iteration in $(seq 1 "$targeted_iteration")
do
echo "iteration:""$iteration"

cat "$project"/binning/bin_"$targeted_iteration".txt | awk '$4>1 {print $2,$6}' | sed 's/;/ /g' | awk -v temp=$iteration '{print $1,$(temp+1)}' > "$project"/temp/id.temp

var2=$(cat "$project"/temp/id.temp | awk '{print $1}')

for bin in $var2
do

cat "$project"/temp/id.temp | awk '$1=="'$bin'" {print $2}' > "$project"/temp/id2.txt

var3=$(cat "$project"/temp/id2.txt)

for idx in $var3
do

cat "$project"/temp/id.temp | awk '$2=="'$idx'" {print "'$bin'",$1}' >> "$project"/temp/louvain_mat.txt

done
done
done 

cat "$project"/temp/louvain_mat.txt | sort | uniq -c | awk '{print $2,$3,$1}' > "$project"/binning/louvain_mat_weighted_"$targeted_iteration".txt

#cleaning of temporary files
rm "$project"/temp/*.txt


