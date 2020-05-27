#!/bin/bash
# Martial Marbouty
# RSG - Meta3C TEAM

# Script alginment = raw alignment data

# usage --> bash alignment.sh NAME_project PATH_raw_assembly


################# input ###################

project=$1
raw_assembly=$2

################# code ####################

mkdir -p "$project"/index/
mkdir -p "$project"/alignment/
mkdir -p "$project"/assembly/

echo "rename and filtering contigs from raw assembly"

bash renamed_assembly.sh "$raw_assembly" "$project"/assembly/"$project".fa
python parse_genome_500.py "$project"/assembly/"$project".fa "$project"/assembly/"$project"_500.fa


echo "Bowtie index building"
bowtie2-build -f "$project"/assembly/"$project"_500.fa "$project"/index/"$project"

echo "Mapping library: ""$project"

echo "Alignment forward reads"
bowtie2 --very-sensitive-local -p 8  -x "$project"/index/"$project" -U "$project"/fastq/"$project"_for.fastq -S "$project"/alignment/"$project"_for.sam

echo "Alignment reverse reads"
bowtie2 --very-sensitive-local -p 8  -x "$project"/index/"$project" -U "$project"/fastq/"$project"_rev.fastq -S "$project"/alignment/"$project"_rev.sam


echo "alignment done"

echo "data treatment and raw network generation"

cat "$project"/alignment/"$project"_for.sam | grep -v "@" | awk '{print $1,$3,$4,$5,$10,$11}'  > "$project"/temp/temp1.sam
cat "$project"/alignment/"$project"_rev.sam | grep -v "@" | awk '{print $1,$3,$4,$5,$10,$11}'  > "$project"/temp/temp2.sam
paste  "$project"/temp/temp1.sam "$project"/temp/temp2.sam | awk '$1==$7 {print $1,$2,$3,$4,$5,$6,$8,$9,$10,$11,$12}' > "$project"/alignement/"$project"_merge.sam

echo "Raw network generated !!!!"

echo "generating BAM files"

samtools view -h -b -S "$project"/alignment/"$project"_for.sam > "$project"/alignment/"$project"_for.bam
samtools view -h -b -S "$project"/alignment/"$project"_rev.sam > "$project"/alignment/"$project"_rev.bam

samtools sort "$project"/alignment/"$project"_for.bam > "$project"/alignment/"$project"_for_sort.bam
samtools sort "$project"/alignment/"$project"_rev.bam > "$project"/alignment/"$project"_rev_sort.bam

echo "cleaning"

rm "$project"/temp/*.sam
rm "$project"/alignment/"$project"_for.bam
rm "$project"/alignment/"$project"_rev.bam
rm "$project"/alignment/"$project"_for.sam
rm "$project"/alignment/"$project"_rev.sam



