#!/bin/bash

#SBATCH --cluster htc
#SBATCH --cpus-per-task=32
#SBATCH -t 23:00:00

usage() { echo -e "SCRIPT FOR SALMON GFP QUANTIFICATION\nUsage: sbatch -o <PROJ_DIR>/OUT_ERR/cellranger_%j.out $0 [-p </path/to/projectdir>] [-d </path/to/fastqdir>] [-n <sample_name>] [-r </path/to/cellranger_ref>]" 1>&2; exit 1; }

while getopts ":p:d:n:r:" arg; do
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
        r)
            REFERENCE=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${PROJ_DIR}" ] || [ -z "${FASTQ_DIR}" ] || [ -z "${SAMPLE_NAME}" ] || [ -z "${REFERENCE}" ]; then
    usage
fi

echo "PROJ_DIR = ${PROJ_DIR}"
echo "FASTQ_DIR = ${FASTQ_DIR}"
echo "SAMPLE_NAME = ${SAMPLE_NAME}"
echo "REFERENCE = ${REFERENCE}"
echo "OUT_DIR = ${PROJ_DIR}/analysis/cellranger"

# check if directory exists, otherwise make it
if [[ ! -d ${PROJ_DIR}/analysis/cellranger ]]; then
    mkdir -p ${PROJ_DIR}/analysis/cellranger
fi

# Must supply -D for working directory output case 
cd ${PROJ_DIR}/analysis/cellranger

/bgfs/lbyrne/sw/cellranger-6.1.2/bin/cellranger count --id=$SAMPLE_NAME --transcriptome=$REFERENCE --fastqs=$FASTQ_DIR --sample=$SAMPLE_NAME --localcores=32 --localmem=64 


