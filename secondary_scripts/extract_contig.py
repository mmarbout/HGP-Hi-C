#!/usr/bin/env python
# -*- coding: utf-8 -*-

from Bio import SeqIO
import sys
#Usage : python extract_ids_fasta.py input.fasta list_ids.txt output.fasta
input_file = sys.argv[1]
id_file = sys.argv[2]
output_file = sys.argv[3]
wanted = set(line.rstrip("\n").split(None,1)[0] for line in open(id_file))
#print("Found %i unique identifiers in %s" % (len(wanted), id_file))
records = (r for r in SeqIO.parse(input_file, "fasta") if r.id in wanted)
count = SeqIO.write(records, output_file, "fasta")
#print("Saved %i records from %s to %s" % (count, input_file, output_file))
#if count < len(wanted):
#print("Warning %i IDs not found in %s" % (len(wanted)-count, input_file))