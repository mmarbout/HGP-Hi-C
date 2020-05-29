# HGP-Hi-C
Hi-C human gut microbiome

these set of scripts allow to reproduce data generated in the publication : Marbouty et al.
"phages - bacteria network of interactions in human gut"

dependencies
-cutadapt
-megahit
-louvain
-bowtie2
-samtools
-python3 (biopython, numpy, scipy, matplotlib


Step 1: Generation of Human gut assemblies
each dataset has been treated the same way
the script will clean the reads using cutadapt and build the assembly using Megahit

> bash 1_assembly.sh "sample" PATH_reads_for PATH_reads_rev PATH_file_adapt 

Step 2: Alignment of 3C reads on their corresponding assemblies
the script will rename the contigs, filter the smallest one (<500bp), align independantly the reads (forward and reverse) and will re-pair them

> bash 2_alignment.sh "sample" PATH_raw_assembly PATH_reads_for PATH_reads_rev

Step3: Generation of contigs network of interactions
the script will generate contigs data (coverage and GC content) and the different network of interactions between contigs (raw, normalized). It will also provide various statistics about the network (3D ratio = PE reads mapping on different contigs / all mapped PE reads)
You have to choose the mapping quality theshold (MQT) - in the publication, we have choosen a mapping quality threshold of 20

> bash 3_network.sh "sample" "MQT"

Step4: iteration of louvain algorithm
the script will perform the different iterations of the louvain algorithm. You will have to specify the number of iterations wanted. For the publication, each network has been treated with 100 iterations.

> bash 4_louvain_iteratif.sh "sample" PATH_network "iterations"

Step5: 
