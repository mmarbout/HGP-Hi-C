
#!/bin/bash
# Martial Marbouty
# RSG - Meta3C TEAM

# Script alginment = raw alignment data

# usage --> bash louvain_iteratif.sh NAME_project PATH_network Mapping_Quality_Threshold(Integer)


################# input ###################

project=$1
network=$2
iterations=$3

############################################# CODE ######################################

mkdir  -p  "$project"/binning/

echo "number of iterations:""$iterations"

#conversion du réseau en fichier binaire
convert -i "$network" -o "$project"/binning/net.bin -w "$project"/binning/net.weights 

# loop des itérations de Louvain
for iteration in $(seq 1 "$iterations")

do
	echo "iteration in progress: iteration n°""$iteration"

	louvain "$project"/binning/net.bin -l -1 -w "$project"/binning/net.weights > "$project"/binning/net.tree
	hierarchy "$project"/binning//net.tree > "$project"/binning/level_louvain.txt 
	level=$(tail -1 "$project"/binning/level_louvain.txt | awk '{print $2}')
	hierarchy "$project"/binning/net.tree -l "$level" > "$project"/temp/output_louvain_"$iteration".txt
	cat "$project"/temp/output_louvain_"$iteration".txt | awk '{print $1}' > "$project"/temp/contig_idx.txt
	cat "$project"/temp/output_louvain_"$iteration".txt | awk '{print $2";"}' > "$project"/temp/bin_idx_"$iteration".txt

done

echo "louvain iterative process finished"
echo "compiling data"

paste "$project"/temp/bin_idx_* | sed 's/\t//g' > "$project"/temp/temp1.txt
paste "$project"/temp/contig_idx.txt "$project"/temp/temp1.txt | awk '{print $1,$2}' > "$project"/binning/output_louvain_"$iterations"it.txt

echo "cleaning"
rm temp/*


