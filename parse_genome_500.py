from Bio import SeqIO
import sys
 
long_sequences = [] # Setup an empty list
handle = open(sys.argv[1], "rU")
for record in SeqIO.parse(handle, "fasta") :
    if len(record.seq) > 499 :
        # Add this record to our list
        long_sequences.append(record)
handle.close()
 
#print "Found %i long sequences" % len(long_sequences)
 
output_handle = open(sys.argv[2], "w")
SeqIO.write(long_sequences, output_handle, "fasta")
output_handle.close()
