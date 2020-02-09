#!/usr/bin/env bash
# Meta3C team
# Martial Marbouty
# Lyam Baudry

############################################# READ ME ######################################

#                              this is the Third script of the Meta3C pipeline
#				Do not forget to fill the paramaters below
#				Launching this script implies that you have already performed the Script1 and Script 2

############################################# PARAMETERS to be fill ######################################

#louvain (i.e. number of iterations you would like to perform - do not perform more than 100 iterations ... :))
iterations=$1
#network input
network=$2
#project name
project=$3
#files should be like that: contig size coverage gc
data_contigs=$4


############################################# CODES ######################################################

################################################# Louvain iterative partitionning ###################################

mkdir -p temp
mkdir -p output/"$project"/iteration
mkdir -p output/"$project"/partition

echo "performing louvain iterative"
echo ""
echo "number of iterations:""$iterations"
echo ""

cat -n "$network" | head -"$iterations" | awk '{print $1}'  > temp/temp_it.txt
cat "$data_contigs" | awk '{print $1,$2,$3,$4}' | sort -k 1b,1 > temp/contig_data.txt

echo "perfoming louvain iterations"

var=$(cat temp/temp_it.txt)

for iteration in $var

do
echo "iteration"
echo ${iteration}

/data-3C-2/louvain/convert_net -i "$network" -o output/"$project"/"$project".bin -w output/"$project"/"$project".weights
/data-3C-2/louvain/louvain output/"$project"/"$project".bin -l -1 -w output/"$project"/"$project".weights > output/"$project"/"$project".tree
/data-3C-2/louvain/hierarchy output/"$project"/"$project".tree > temp/output_louvain.txt
tail -1 temp/output_louvain.txt | awk '{print $2}' | sed 's/://g' > temp/level.txt
level=$(cat temp/level.txt)
echo "level used"
echo "${level}"
/data-3C-2/louvain/hierarchy output/"$project"/"$project".tree -l ${level} > temp/iteration.txt
awk '{print $1,$2}' temp/iteration.txt | sort -k 1,1 > temp/index.txt
awk '{print $1}' temp/index.txt > output/"$project"/iteration/index_community.txt
awk '{print $2";"}' temp/index.txt > output/"$project"/iteration/"$iteration".community

echo ""

done


echo "iterations finished"
echo ""

#generation of Louvain iterations data

echo "generation of Louvain iterations data files"
echo ""

echo "1" > temp/n_it.temp
echo "5" >> temp/n_it.temp
echo "10" >> temp/n_it.temp
echo "20" >> temp/n_it.temp
echo "30" >> temp/n_it.temp
echo "40" >> temp/n_it.temp
echo "50" >> temp/n_it.temp
echo "60" >> temp/n_it.temp
echo "70" >> temp/n_it.temp
echo "80" >> temp/n_it.temp
echo "90" >> temp/n_it.temp
echo "100" >> temp/n_it.temp


line=$(grep -n "$iterations" temp/n_it.temp | head -1 | awk -F ":" '{print $1}')
var=$(cat temp/n_it.temp | head -"$line" )

rm output/"$project"/partition/*.louv
rm temp/*.louv

for repet in $var
do
echo "$repet"

echo "$repet" >> temp/regression_louvain100.louv
echo "$repet" >> temp/regression_louvain500.louv
echo "$repet" >> temp/regression_louvain1000.louv

paste output/"$project"/iteration/*.community | sed 's/\t//g' | awk -F ";" -v f=1 -v t="$repet" '{for(i=f;i<=t;i++) printf("%s%s%s",$i,";",(i==t)?"\n":OFS)}' | sed 's/; /;/g'  > temp/community.temp
paste output/"$project"/iteration/index_community.txt temp/community.temp | sort -k 2b,2 > temp/contig_community_"$repet".txt

cat temp/contig_community_"$repet".txt | awk '{print $2}' | sort | uniq -c | sort -k 1,1 -g -r > temp/tmp.txt
cat -n temp/tmp.txt | awk '{print "core",$1,"size",$2,"index",$3}' > output/"$project"/partition/core_"$repet".txt

cat output/"$project"/partition/core_"$repet".txt | awk '{print $2,$4,$6}' | sort -k 3b,3 > temp/core_trie.temp

join -12 -23 temp/contig_community_"$repet".txt temp/core_trie.temp | awk '{print $2,$3,$4}' | sort -k 1b,1 > temp/contig_core_"$repet".txt

join -11 -21 temp/contig_data.txt temp/contig_core_"$repet".txt | sort -k 5,5 > temp/contig_data_"$repet".txt

var3=$(cat temp/contig_core_"$repet".txt | awk '$3 > 1 {print $2}' | sort -u)

rm temp/core_data2.txt
rm temp/all_core_data.txt

for core in $var3
do

cat temp/contig_data_"$repet".txt | awk '$5=="'$core'" {print $0}' > temp/core_data.txt
cat temp/contig_data_"$repet".txt | awk '$5=="'$core'" {print $5,$6}' | head | sort -u >> temp/core_data2.txt
cat temp/core_data.txt | awk '{sum+=$2} END {print sum}' >> temp/all_core_data.txt

done

#core_data = idcore _ nb contigs _ size(pb)
#contig_data = contig _ size _ coverage _ gc _ idcore _ nbcontigs _ size(pb)

paste temp/core_data2.txt temp/all_core_data.txt | sort -k 1,1 > output/"$project"/partition/core_data_"$repet".txt
join -15 -21 temp/contig_data_"$repet".txt output/"$project"/partition/core_data_"$repet".txt | awk '{print $2,$3,$4,$5,$1,$6,$8}' > output/"$project"/partition/contig_data_"$repet".txt

awk '$3 > 100000 && $3 < 500000 {print '$repet',$0}' output/"$project"/partition/core_data_"$repet".txt | wc -l  >> temp/regression_louvain100_2.louv
awk '$3 > 500000 && $3 < 1000000 {print '$repet',$0}' output/"$project"/partition/core_data_"$repet".txt | wc -l  >> temp/regression_louvain500_2.louv
awk '$3 > 1000000 {print '$repet',$0}' output/"$project"/partition/core_data_"$repet".txt | wc -l >> temp/regression_louvain1000_2.louv

awk '{sum+=$2} END {print sum}' temp/contig_data.txt > temp/hist.txt
awk '$3 < 1000  {print $3}' output/"$project"/partition/core_data_"$repet".txt | awk '{sum+=$1} END {print sum}' >> temp/hist.txt
awk '$3 >= 1000 && $3 < 10000 {print $3}' output/"$project"/partition/core_data_"$repet".txt | awk '{sum+=$1} END {print sum}' >> temp/hist.txt
awk '$3 >= 10000 && $3 < 50000 {print $3}' output/"$project"/partition/core_data_"$repet".txt | awk '{sum+=$1} END {print sum}' >> temp/hist.txt
awk '$3 >= 50000 && $3 < 100000 {print $3}' output/"$project"/partition/core_data_"$repet".txt | awk '{sum+=$1} END {print sum}' >> temp/hist.txt
awk '$3 >= 100000 && $3 < 250000 {print $3}' output/"$project"/partition/core_data_"$repet".txt | awk '{sum+=$1} END {print sum}' >> temp/hist.txt
awk '$3 >= 250000 && $3 < 500000 {print $3}' output/"$project"/partition/core_data_"$repet".txt | awk '{sum+=$1} END {print sum}' >> temp/hist.txt
awk '$3 >= 500000 && $3 < 1000000 {print $3}' output/"$project"/partition/core_data_"$repet".txt | awk '{sum+=$1} END {print sum}' >> temp/hist.txt
awk '$3 >= 1000000 {print $3}' output/"$project"/partition/core_data_"$repet".txt | awk '{sum+=$1} END {print sum}' >> temp/hist.txt

cat temp/hist.txt > temp/repartition.txt

echo "total" > temp/hist.txt
echo "core<1Kb" >> temp/hist.txt
echo "1Kb<core<10Kb" >> temp/hist.txt
echo "10Kb<core<50Kb" >> temp/hist.txt
echo "50Kb<core<100Kb" >> temp/hist.txt
echo "100Kb<core<250Kb" >> temp/hist.txt
echo "250Kb<core<500Kb" >> temp/hist.txt
echo "500<core<1000Kb" >> temp/hist.txt
echo "core>1000Kb" >> temp/hist.txt

cat temp/hist.txt > temp/id_repartition.txt
paste temp/id_repartition.txt temp/repartition.txt | awk '{print $1,$2,"0"}' | awk '{print $1,$2}' > output/"$project"/partition/repartition_"$repet".txt

scripts/./analyse_repartition.r output/"$project"/partition/repartition_"$repet".txt output/"$project"/partition/repartition_"$repet".pdf

echo ""
done

paste temp/regression_louvain100.louv temp/regression_louvain100_2.louv > output/"$project"/partition/regression_louvain100.louv
paste temp/regression_louvain500.louv temp/regression_louvain500_2.louv > output/"$project"/partition/regression_louvain500.louv
paste temp/regression_louvain1000.louv temp/regression_louvain1000_2.louv > output/"$project"/partition/regression_louvain1000.louv

#Figures generation

scripts/./analyse_louvain.r output/"$project"/partition/regression_louvain100.louv output/"$project"/partition/regression_louvain500.louv output/"$project"/partition/regression_louvain1000.louv output/"$project"/partition/regression_louvain.pdf


echo "cleaning"

rm temp/*.temp
rm temp/*.tree
rm temp/*.weights
rm temp/*.txt
rm temp/*.bin
rm temp/*.target

echo "Meta3C iterative procedure finished"


