#!/usr/bin/env bash
# Meta3C
# Martial Marbouty

############################################# PARAMETERS ######################################

#usage --> renamed_contigs_assembly.sh PATH_initial_contigs PATH_renamed_contigs

#path to initial contigs
contigs=$1

#path to final contigs
renamed_contigs=$2

############################################# CODE ######################################

#remove all the headers and replace them by simplified headers

echo "renamed contigs"

cat "$contigs" | sed 's/>/> /' | sed 's/=/ /g' | sed 's/_/ /g' | awk '{if ($1==">") print $1"NODE_"$3"_length_"$9 ; else print $0}' > "$renamed_contigs"

echo "done"

