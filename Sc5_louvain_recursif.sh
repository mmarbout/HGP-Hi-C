#!/usr/bin/env bash
# Meta3C team
# Martial Marbouty
# Lyam Baudry

############################################# PARAMETERS to be fill ######################################

#project name
project=$1

#louvain (number of iterations for the recursive process)
iterations=$2

#louvain level
targeted_iteration=$3

#overlappingthreshold
threshold=$4

#targeted_bin --> must provides a file containing the targeted bin (i.e. the overlapping communities)
targeted_bin=$5

#files should be like that: contig size coverage gc
data_contigs=$6

#repertory containing contigs in fasta
#contigs=/media/rsg/3C-data2/INRA/assembly/fasta_contig
contigs=$7
############################################# CODE ######################################

echo "cleaning previous files versions"
rm output/"$project"/overlapping_fasta"$threshold"_recursiveprocess/*.fa
rm -r output/"$project"/overlapping_data"$threshold"_recursiveprocess/


mkdir -p output/"$project"/overlapping_fasta"$threshold"_recursiveprocess/
mkdir -p output/"$project"/overlapping_data"$threshold"_recursiveprocess/

cat "$data_contigs" | sort -k 1,1 > temp/contig_data.txt

var=$(cat "$targeted_bin")

for bin in $var
do 

echo "bin in progress:""$bin"
mkdir -p output/"$project"/overlapping_data"$threshold"_recursiveprocess/"$bin"

echo "number of iterations:""$iterations"
echo "perfoming louvain iterations"

cat -n Sc1_louvain_iterative.sh | head -"$iterations" | awk '{print $1}'  > temp/temp_it.txt

var=$(cat temp/temp_it.txt)

for iteration in $var
do
echo "iteration"
echo ${iteration}

louvain/convert_net -i output/"$project"/subnetwork_overlapping"$threshold"/network_"$bin".txt -o temp/tmp.bin -w temp/tmp.weights
louvain/louvain temp/tmp.bin -l -1 -w temp/tmp.weights > temp/tmp.tree
louvain/hierarchy temp/tmp.tree > temp/output_louvain.txt
tail -1 temp/output_louvain.txt | awk '{print $2}' | sed 's/://g' > temp/level.txt
level=$(cat temp/level.txt)
echo "level used"
echo "${level}"
louvain/hierarchy temp/tmp.tree -l ${level} > temp/iteration.txt
awk '{print $1,$2}' temp/iteration.txt | sort -k 1,1 > temp/index.txt
awk '{print $1}' temp/index.txt > output/"$project"/overlapping_data"$threshold"_recursiveprocess/"$bin"/index_community.txt
awk '{print $2";"}' temp/index.txt > output/"$project"/overlapping_data"$threshold"_recursiveprocess/"$bin"/"$iteration".community
done

echo "iterations finished"

paste output/"$project"/overlapping_data"$threshold"_recursiveprocess/"$bin"/*.community | sed 's/\t//g' | awk -F ";" -v f=1 -v t="$iterations" '{for(i=f;i<=t;i++) printf("%s%s%s",$i,";",(i==t)?"\n":OFS)}' | sed 's/; /;/g'  > temp/community.temp
paste output/"$project"/overlapping_data"$threshold"_recursiveprocess/"$bin"/index_community.txt temp/community.temp | sort -k 2,2 > temp/contig_community_"$iterations".txt

cat temp/contig_community_"$iterations".txt | awk '{print $2}' | sort | uniq -c | sort -k 1,1 -g -r > temp/tmp.txt
cat -n temp/tmp.txt | awk '{print "core",$1,"size",$2,"index",$3}' > output/"$project"/overlapping_data"$threshold"_recursiveprocess/"$bin"/core_"$iterations".txt

cat output/"$project"/overlapping_data"$threshold"_recursiveprocess/"$bin"/core_"$iterations".txt | awk '{print $2,$4,$6}' | sort -k 3,3 > temp/core_trie.temp
join -12 -23 temp/contig_community_"$iterations".txt temp/core_trie.temp | awk '{print $2,$3,$4}' | sort -k 1,1 > temp/contig_core_"$iterations".txt

join -11 -21 temp/contig_data.txt temp/contig_core_"$iterations".txt | sort -k 5,5 > temp/contig_data_"$iterations".txt

var3=$(cat temp/contig_core_"$iterations".txt | awk '$3 > 1 {print $2}' | sort -u)

rm temp/core_data2.txt
rm temp/all_core_data.txt

for core in $var3
do

cat temp/contig_data_"$iterations".txt | awk '$5=="'$core'" {print $0}' > temp/core_data.txt
cat temp/contig_data_"$iterations".txt | awk '$5=="'$core'" {print $5,$6}' | head | sort -u >> temp/core_data2.txt
cat temp/core_data.txt | awk '{sum+=$2} END {print sum}' >> temp/all_core_data.txt

done

paste temp/core_data2.txt temp/all_core_data.txt | sort -k 1,1 > output/"$project"/overlapping_data"$threshold"_recursiveprocess/"$bin"/core_data_"$iterations".txt
join -15 -21 temp/contig_data_"$iterations".txt output/"$project"/overlapping_data"$threshold"_recursiveprocess/"$bin"/core_data_"$iterations".txt | awk '{print $2,$3,$4,$5,$1,$6,$8}' > output/"$project"/overlapping_data"$threshold"_recursiveprocess/"$bin"/contig_data_"$iterations".txt

var4=$(cat output/"$project"/overlapping_data"$threshold"_recursiveprocess/"$bin"/core_data_"$iterations".txt | awk '$3>=5000 {print $1}')
for core in $var4
do
#cat output/"$project"/overlapping_data"$threshold"_recursiveprocess/"$bin"/contig_data_"$iterations".txt | awk '$5=="'$core'" {print "k141_"$1}' > temp/node.txt
cat output/"$project"/overlapping_data"$threshold"_recursiveprocess/"$bin"/contig_data_"$iterations".txt | awk '$5=="'$core'" {print "NODE_"$1"_length_"$2"_cov_0"}' > temp/node.txt
var5=$(cat temp/node.txt)
for node in $var5
do
cat "$contigs"/"$node".fa >> output/"$project"/overlapping_fasta"$threshold"_recursiveprocess/"$bin"_"$core".fa
done
done

done
