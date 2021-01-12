# HGP-Hi-C

publication : MetaHiC phage bacteria infection network reveal active cycling phages of the healthy human gut

Martial Marbouty, Agnès Thierry, Gaël A. Millot & Romain Koszul

# 1 - Datasets 
you will find 3 files containing data about MAGs, Contigs and Phages characterized in our study.

Supplementary Dataset 1: MAGs data 
Comma separated file containing data about the characterized MAGs: sample, bin id, bin size, bin mean GC content, bin mean coverage, taxonomy (7 levels), completion, contamination, contigs number, N50, mean contig size, longest contig, coding density.

Supplementary Dataset 2: contigs data
Comma separated file containing data about all the binned contigs into MAGs: sample, contig id, contig size, contig coverage, contig GC content, associated bin.

Supplementary Dataset 3: phages contigs data
Comma separated file containing data about all the phages’ contigs associated to MAGs: sample, contig id, associated bin.


# 2 - Scripts

these set of scripts allow to reproduce data generated in the publication : Marbouty et al.

(example using sample 10015 are provided)

"Phages - bacteria interactions network of the healthy human gut"

dependencies:

-cutadapt

-megahit

-louvain

-bowtie2

-samtools

-python3 (biopython, numpy, scipy, matplotlib


Step 1: Generation of Human gut assemblies (all assemblies can be found on the NCBI - PRJNA627086)

each dataset has been treated the same way

the script will clean the reads using cutadapt and build the assembly using Megahit

> bash 1_assembly.sh "sample" PATH_reads_for PATH_reads_rev PATH_file_adapt

> bash 1_assembly.sh 10015 fastq/10015_for.fastq fastq/10015_rev.fastq divers/adapt.fa

Step 2: Alignment of 3C reads on their corresponding assemblies

the script will rename the contigs, filter the smallest one (<500bp), align independantly the reads (forward and reverse) and will re-pair them

> bash 2_alignment.sh "sample" PATH_raw_assembly PATH_reads_for PATH_reads_rev

> bash 2_alignment.sh 10015 10015/assembly/10015.fa 10015/fastq/10015_for.fastq 10015/fastq/10015_rev.fastq

Step3: Generation of contigs network of interactions

the script will generate contigs data (coverage and GC content) and the different network of interactions between contigs (raw, normalized). It will also provide various statistics about the network (3D ratio = PE reads mapping on different contigs / all mapped PE reads).
You have to choose the mapping quality theshold (MQT) - in the publication, we have choosen a mapping quality threshold of 20

> bash 3_network.sh "sample" "MQT"

> bash 3_network.sh 10015 20

Step4: iteration of louvain algorithm

the script will perform the different iterations of the louvain algorithm. You will have to specify the number of iterations wanted. For the publication, each network has been treated with 100 iterations. You can perform more iterations as you will choose at which iteration you extract the bins in the next step.

> bash 4_louvain_iteratif.sh "sample" PATH_network "iterations"

> bash 4_louvain_iteratif.sh 10015 10015/network/10015_network_norm.txt 100

Step5: louvain data treatment

the script will extract bins and contigs data after a defined number of iterations (but you will have first to specify the number of iterations you have done previously. (for the publication, we have set it to 100 also). The script will also build a distance matrice based on the louvain procedure. This matrice will be used after to extract overlapping bins.

> bash 5_louvain_data_treatment.sh "sample" "iterations" "targeted iteration"

> bash 5_louvain_data_treatment.sh 10015 100 100

step6: bin extraction

the script will generate fasta files for the different bins above 500Kb given a certain number of iterations and a threshold for the overlapping bins (ex:contigs that are group together at least during 90 iterations over 100 are grouped together).

> bash 6_recover_bin.sh "sample" "iterations" "targeted iteration" "overlapping threshold"
> bash 6_recover_bin.sh 10015 100 100 90

step7: bin evaluation

we use CheckM (Parks et al. 2018) to evaluate the MAGs.

step8: recursive procedure

the script will extract subnetwork of each targeted bin and perform a louvain recursive procedure on them. you have to provide a file containing the different concerned bins.

> bash 7_recursive.sh "sample" "file with the tageted bin" "recursive iterations" "intitial iteration" "overlapping threshold" "network" "assembly"

> bash 7_recursive.sh 10015 10 100 90 10015/network/10015_network_norm.txt 10015/assembly/10015_500.fa

