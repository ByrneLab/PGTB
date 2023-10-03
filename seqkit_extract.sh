#!/bin/bash

#SBATCH --cluster htc
#SBATCH --cpus-per-task=2
#SBATCH -t 2:00:00 # Runtime in D-HH:MM

usage() { echo -e "SCRIPT FOR SEQKIT GFP READ EXTRACT\nUsage: sbatch -o <PROJ_DIR>/OUT_ERR/seqkit_%j.out $0 [-p </path/to/projectdir>] [-d </path/to/fastqdir>] [-n <sample_name>] [-b <gfp_barcodes_fasta>]" 1>&2; exit 1; }

while getopts ":p:d:n:b:" arg; do
    case $arg in
        p)
            PROJ_DIR=${OPTARG}
            ;;
        d)
            FASTQ_DIR=${OPTARG}
            ;;
        n)
            SAMPLE_NAME=${OPTARG}
            ;;
	b)
	    BARCODES=${OPTARG}
	    ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${PROJ_DIR}" ] || [ -z "${FASTQ_DIR}" ] || [ -z "${SAMPLE_NAME}" ] || [ -z "${BARCODES}" ]; then
    usage
fi

echo "PROJ_DIR = ${PROJ_DIR}"
echo "FASTQ_DIR = ${FASTQ_DIR}"
echo "SAMPLE_NAME = ${SAMPLE_NAME}"
echo "BARCODES = ${BARCODES}"

module load seqkit/0.16.0

cut -f 4 ${PROJ_DIR}/analysis/salmon_quant/${SAMPLE_NAME}_R2_salmon.bed > ${PROJ_DIR}/analysis/salmon_quant/${SAMPLE_NAME}_R2_salmon.gfp_readnames.txt

seqkit grep -f ${PROJ_DIR}/analysis/salmon_quant/${SAMPLE_NAME}_R2_salmon.gfp_readnames.txt ${FASTQ_DIR}/${SAMPLE_NAME}_R2_001.fastq.gz -o ${PROJ_DIR}/analysis/salmon_quant/${SAMPLE_NAME}_R2_001.subgfp.fastq

seqkit grep -f ${PROJ_DIR}/analysis/salmon_quant/${SAMPLE_NAME}_R2_salmon.gfp_readnames.txt ${FASTQ_DIR}/${SAMPLE_NAME}_R1_001.fastq.gz -o ${PROJ_DIR}/analysis/salmon_quant/${SAMPLE_NAME}_R1_001.subgfp.fastq

seqkit locate -f ${BARCODES} ${PROJ_DIR}/analysis/salmon_quant/${SAMPLE_NAME}_R2_001.subgfp.fastq > ${PROJ_DIR}/analysis/salmon_quant/${SAMPLE_NAME}_R2_001.subgfp.seqkitlocate.txt

sed -i 1d ${PROJ_DIR}/analysis/salmon_quant/${SAMPLE_NAME}_R2_001.subgfp.seqkitlocate.txt

paste <(seqkit subseq -r 1:16 ${PROJ_DIR}/analysis/salmon_quant/${SAMPLE_NAME}_R1_001.subgfp.fastq | seqkit fx2tab | awk '{print $1"\t"$3}') <(seqkit subseq -r 17:28 ${PROJ_DIR}/analysis/salmon_quant/${SAMPLE_NAME}_R1_001.subgfp.fastq | seqkit fx2tab | awk '{print $3}') > ${PROJ_DIR}/analysis/salmon_quant/${SAMPLE_NAME}_10x_bc_umi.txt
