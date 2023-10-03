#!/bin/bash

#SBATCH --cluster htc
#SBATCH --cpus-per-task=8
#SBATCH -t 2:00:00 # Runtime in D-HH:MM


usage() { echo -e "SCRIPT FOR SALMON GFP QUANTIFICATION\nUsage: sbatch -o <PROJ_DIR>/OUT_ERR/salmon_gfp_quant_%j.out $0 [-p </path/to/projectdir>] [-d </path/to/fastqdir>] [-n <sample_name>] [-r </path/to/salmon_index_ref>]" 1>&2; exit 1; }

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
NAME="${SAMPLE_NAME}_R2_salmon"
echo "SALMON_ID = ${NAME}"
echo "REFERENCE = ${REFERENCE}"

module load salmon/1.8.0
module load bedops/2.4.35
module load gcc/8.2.0
module load samtools

R2_FASTQ="${FASTQ_DIR}/${SAMPLE_NAME}_R2_001.fastq.gz"
# check if file exists
if [[ ! -f ${R2_FASTQ} ]]; then
    echo "${R2_FASTQ} does not exist. Check input"
    exit
fi

OUT_DIR="${PROJ_DIR}/analysis/salmon_quant"
# create analysis/salmon directory for salmon output
if [[ ! -d ${OUT_DIR} ]]; then
    echo "Creating ${OUT_DIR}"
    mkdir -p ${OUT_DIR}
fi

OUT_SAM="$OUT_DIR/$NAME.sam"
OUT_QUANT="$OUT_DIR/${NAME}_quant"
OUT_BED="$OUT_DIR/$NAME.bed"

cd $OUT_DIR

salmon quant -i $REFERENCE -l U -r <(gunzip -c $R2_FASTQ) --writeMapping=$OUT_SAM -o $OUT_QUANT --threads 8

convert2bed --input=sam < $OUT_SAM > $OUT_BED
