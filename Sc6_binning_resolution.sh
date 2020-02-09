#!/usr/bin/env bash
# Meta3C team
# Martial Marbouty
# Lyam Baudry

############################################# PARAMETERS to be fill ######################################

#project name
project=$1

#louvain level
targeted_iteration=$2

#overlappingthreshold
threshold=$3

#targeted_bin --> must provides a file containing the targeted bin (i.e. the overlapping communities)
recursif_bin=$4

############################################# CODE ######################################

echo "cleaning previous files versions"

mkdir -p output/"$project"/final_data_"$targeted_iteration"_th"$threshold"/
mkdir -p output/"$project"/final_fasta_"$targeted_iteration"_th"$threshold"/

rm temp/final_data_contigs.txt
rm output/"$project"/final_fasta_"$targeted_iteration"_th"$threshold"/*.fa

##############################################################################################################

echo "recovering data for bin processed by recursive procedure"

var1=$(cat "$recursif_bin")

cp output/"$project"/overlapping_fasta"$threshold"_recursiveprocess/*.fa output/"$project"/final_fasta_"$targeted_iteration"_th"$threshold"/

for bin_re in $var1
do 
cat output/"$project"/overlapping_data"$threshold"_recursiveprocess/"$bin_re"/contig_data_10.txt | awk '{print "NODE_"$1"_length_"$2"_cov_0",$1,$2,$3,$4,"'$bin_re'""_"$5,$6,$7}' >> temp/final_data_contigs.txt
done

##############################################################################################################

echo "recovering data for bin processed by iterative procedure"

ls -l output/"$project"/overlapping_data"$threshold"/ | grep "overcomm_data" | awk '{print $9}' | sed 's/.txt//' | sed 's/overcomm_data_//' > temp/temp1.txt
cat "$recursif_bin" temp/temp1.txt | sort | uniq -c | awk '$1<2 {print $2}' > temp/bin_iteratif.txt

var2=$(cat temp/bin_iteratif.txt)
for bin_it in $var2
do 
cat output/"$project"/overlapping_fasta"$threshold"/overlapping"$bin_it".fa > output/"$project"/final_fasta_"$targeted_iteration"_th"$threshold"/"$bin_it"_0.fa

cat output/"$project"/overlapping_data"$threshold"/overcomm_data_"$bin_it".txt \
  | awk '{print $1,$2,$3,$4,$5,"'$bin_it'""_0",$11,$12}' >> temp/final_data_contigs.txt

done

cat temp/final_data_contigs.txt | sort -k 6,6 > temp/final_data_contigs_sorted.txt

##############################################################################################################

echo "compiling bin data"

cat temp/final_data_contigs_sorted.txt \
  | awk '{print $6,$8}' \
  | sort -u \
  | sort -k 2,2 -g -r > temp/temp1.txt

cat -n temp/temp1.txt | sort -k 2,2 >  output/"$project"/final_data_"$targeted_iteration"_th"$threshold"/final_data_bin.txt

join -12 -26 output/"$project"/final_data_"$targeted_iteration"_th"$threshold"/final_data_bin.txt temp/final_data_contigs_sorted.txt | awk '{print $4,$5,$6,$7,$8,$1,$2,$3}' > output/"$project"/final_data_"$targeted_iteration"_th"$threshold"/final_data_contigs.txt

##############################################################################################################

echo "generating figures"

cat output/"$project"/final_data_"$targeted_iteration"_th"$threshold"/final_data_contigs.txt | awk '$8>=300000 {print $2,$4,$5,$6}' > temp/bin_data.txt 

scripts/./analyse_core.r temp/bin_data.txt output/"$project"/final_data_"$targeted_iteration"_th"$threshold"/cov.pdf output/"$project"/final_data_"$targeted_iteration"_th"$threshold"/GC.pdf

##############################################################################################################

echo "generating louvain matrice for final bins"
echo ""

echo "removing previous files"
rm output/"$project"/final_data_"$targeted_iteration"_th"$threshold"/louvain_mat_recursif.txt
rm output/"$project"/final_data_"$targeted_iteration"_th"$threshold"/louvain_mat_recursif_weighted.txt
rm output/"$project"/final_data_"$targeted_iteration"_th"$threshold"/core_recursif_idx.txt
echo ""

############" core data" #######################"""


cat output/"$project"/partition/core_"$targeted_iteration".txt | awk '{print $2,"0",$6}' | sort -k 1,1  > temp/bin_id.txt
cat output/"$project"/final_data_"$targeted_iteration"_th"$threshold"/final_data_bin.txt | sed 's/_/ /' | sort -k 2,2 > temp/bin_id2.txt
join -11 -22 temp/bin_id.txt temp/bin_id2.txt | awk '{print $4,$1"_"$5,$3}' | sort -k 2,2 > temp/bin_idx.txt


var2=$(cat temp/bin_iteratif.txt | awk '{print $1"_0"}')

echo "data for iteratif bins"

for bin_it in $var2
do 
cat temp/bin_idx.txt | awk '$2=="'$bin_it'" {print $1,$3"0""'$bin_it'"";0""'$bin_it'"";0""'$bin_it'"";0""'$bin_it'"";0""'$bin_it'"";0""'$bin_it'"";0""'$bin_it'"";0""'$bin_it'"";0""'$bin_it'"";0""'$bin_it'"}' >> output/"$project"/final_data_"$targeted_iteration"_th"$threshold"/core_recursif_idx.txt
done

echo "data for recursif bins"

var1=$(cat "$recursif_bin")

for bin_re in $var1
do 
cat output/"$project"/overlapping_data"$threshold"_recursiveprocess/"$bin_re"/core_10.txt | awk '$4>=2 {print "'$bin_re'""_0","'$bin_re'""_"$2,$6}' | sort -k 2,2 > temp/bin_re_id.txt
join -12 -22 temp/bin_idx.txt temp/bin_re_id.txt | awk '{print $2,$3$5}' >> output/"$project"/final_data_"$targeted_iteration"_th"$threshold"/core_recursif_idx.txt
done



####################################
echo "generating louvain matrice for recursif binning"

targeted_iteration_V2=$(echo "$targeted_iteration" | awk -v temp=$targeted_iteration '{print temp+10}')

for iteration in $(seq 1 "$targeted_iteration_V2")
do

echo "iteration:""$iteration"

cat output/"$project"/final_data_"$targeted_iteration"_th"$threshold"/core_recursif_idx.txt | awk '{print $1,$2}' | sed 's/;/ /g' | awk -v temp=$iteration '{print $1,$(temp+1)}' > temp/id.temp

var2=$(cat temp/id.temp | awk '{print $1}')

for core in $var2
do

#echo "core in prgress:""$core"
cat temp/id.temp | awk '$1=="'$core'" {print $2}' > temp/id2.txt

var3=$(cat temp/id2.txt)

for idx in $var3
do

cat temp/id.temp | awk '$2=="'$idx'" {print "'$core'",$1}' >> output/"$project"/final_data_"$targeted_iteration"_th"$threshold"/louvain_mat_recursif.txt

done
done
done 

cat output/"$project"/final_data_"$targeted_iteration"_th"$threshold"/louvain_mat_recursif.txt | sort | uniq -c | awk '{print $2,$3,$1"\n"$3,$2,$1}' > output/"$project"/final_data_"$targeted_iteration"_th"$threshold"/louvain_mat_recursif_weighted.txt



