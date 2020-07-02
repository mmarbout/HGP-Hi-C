#!/bin/bash
# Martial Marbouty
# RSG - Meta3C TEAM

# Script alginment = raw alignment data

# usage --> bash alignment.sh NAME_project PATH_raw_assembly


################# input ###################

project=$1
raw_assembly=$2
reads_for=$3
reads_rev=$4

################# code ####################

mkdir -p "$project"/index/
mkdir -p "$project"/alignment/
mkdir -p "$project"/assembly/

echo "rename and filtering contigs from raw assembly"

bash secondary_scripts/renamed_contigs_assembly.sh "$raw_assembly" "$project"/assembly/"$project".fa
python secondary_scripts/parse_genome_500.py "$project"/assembly/"$project".fa "$project"/assembly/"$project"_500.fa


echo "Bowtie index building"
bowtie2-build -f "$project"/assembly/"$project"_500.fa "$project"/index/"$project"

echo "Mapping library: ""$project"

echo "Alignment forward reads"
bowtie2 --very-sensitive-local -p 8  -x "$project"/index/"$project" -U "$reads_for" -S "$project"/alignment/"$project"_for.sam

echo "Alignment reverse reads"
bowtie2 --very-sensitive-local -p 8  -x "$project"/index/"$project" -U "$reads_rev" -S "$project"/alignment/"$project"_rev.sam


echo "alignment done"

echo "data treatment and compilation"

cat "$project"/alignment/"$project"_for.sam | grep -v "@" | awk '{print $1,$3,$4,$5,$10,$11}' | sort -k 1,1 > "$project"/temp/temp1.sam
cat "$project"/alignment/"$project"_rev.sam | grep -v "@" | awk '{print $1,$3,$4,$5,$10,$11}' | sort -k 1,1 > "$project"/temp/temp2.sam
join -11 -21  "$project"/temp/temp1.sam "$project"/temp/temp2.sam > "$project"/alignment/"$project"_merge.sam

echo "data compiled !!!!"

echo "generating BAM files"

samtools view -h -b -S "$project"/alignment/"$project"_for.sam > "$project"/alignment/"$project"_for.bam
samtools view -h -b -S "$project"/alignment/"$project"_rev.sam > "$project"/alignment/"$project"_rev.bam

samtools sort "$project"/alignment/"$project"_for.bam  "$project"/alignment/"$project"_for_sort
samtools sort "$project"/alignment/"$project"_rev.bam  "$project"/alignment/"$project"_rev_sort

echo "cleaning"

rm "$project"/temp/*.sam
rm "$project"/alignment/"$project"_for.bam
rm "$project"/alignment/"$project"_rev.bam
rm "$project"/alignment/"$project"_for.sam
rm "$project"/alignment/"$project"_rev.sam



