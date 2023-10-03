#!/bin/bash

#SBATCH --cluster htc
#SBATCH --cpus-per-task=2
#SBATCH -t 02:00 # Runtime in D-HH:MM
 
module load salmon/1.8.0

KLEN=31
REF_FASTA=$1
INDEX=$2

salmon index --transcripts $REF_FASTA --kmerLen $KLEN --index $INDEX
