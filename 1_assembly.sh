#!/bin/bash
# Martial Marbouty
# RSG - Meta3C TEAM

# Script assembly = reads cleaning + assembly step

# usage --> bash assembly.sh NAME_project PATH_reads_for PATH_reads_reverse PATH_adapt_file 


################# input ###################

project=$1
reads_for=$2
reads_rev=$3
adapt=$4


################ code #####################@

echo "project"

mkdir -p "$project"/temp/
mkdir -p "$project"/fastq/

echo "cleaning reads"

cutadapt  -a file:"$adapt" -A file:"$adapt" --match-read-wildcards -o "$project"/temp/temp_for.fastq -p "$project"/temp/temp_rev.fastq  -q 20,20 -m 45 "$reads_for" "$reads_rev"

cutadapt -a GGGGGGGGG -A GGGGGGG -o "$project"/fastq/"$project"_for.fastq -p "$project"/fastq/"$project"_rev.fastq  -m 45 -O 5 "$project"/temp/temp_for.fastq "$project"/temp/temp_rev.fastq

rm "$project"/temp/*.fastq

echo "starting assembly"

megahit/./megahit -1 "$project"/fastq/"$project"_for.fastq -2 "$project"/fastq/"$project"_rev.fastq -t 5 -m 126 -o "$project"/assembly/
