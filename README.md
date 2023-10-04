# PGTB
Pittsburgh Gene Therapy Bootcamp 2023 (scAAVengr)

## scAAVengr Pipeline
![alt text](https://github.com/ByrneLab/PGTB/blob/main/img/scaavengr_pipeline.png?raw=true)


## Getting started

### Access HTC CRC

  1. If you're not on Pitt WifI:
        - Download PulseSecure or GlobalProtect VPN
        - https://www.technology.pitt.edu/services/pittnet-vpn-globalprotect 
        - Setup vpn/2FA
        - Connect to Pitt
  2. Login to Pitt CRC
        - Open up Terminal
        - ssh <pitt_username>@htc.crc.pitt.edu
        - Enter password: <pitt_login_password>
  3. Set up Anaconda / conda env
        - mkdir ${$HOME}/resources
        - cp /bgfs/lbyrne/Anaconda3-2020.11-Linux-x86_64.sh ${$HOME}/resources/
        - cd ${$HOME}/resources/
        - bash Anaconda3-2020.11-Linux-x86_64.sh
        - conda env create -f /bgfs/lbyrne/PGTB/resources/scaavengr_env.yml
  4. Clone scAAVengr repository
        - mkdir ${HOME}/git_repos
        - cd ${HOME}/git_repos
        - git clone https://github.com/ByrneLab/PGTB.git
  5. Set up project direcotry
     - sample metadata file
     - directory structure
         - analysis
             - salmon_quant
             - cellranger
         - OUT_ERR
           

## Pre-run checks

1. Check/download reference genome
2. Check/create GFP reference file
   - Submit salmon index to create indexed reference file
3. Create conda env
   - conda env create -f /bgfs/lbyrne/PGTB/resources/scaavengr_env.yml

## Run scAAVengr

### Pre-processing pipeline 


#### scRNAseq

Submit Cellranger
```
sbatch -o `pwd`/OUT_ERR/cellranger_%j.out ~/git_repos/PGTB/submit_cellranger.sh \
    -p `pwd` \
    -d /bgfs/lbyrne/PGTB/data/ \
    -n LB1_BYR819A1 \
    -r /bgfs/lbyrne/PGTB/resources/refdata-gex-GRCh38-2020-A/
```

#### GFP quantification

Submit salmon GFP quantification
```
sbatch -o `pwd`/OUT_ERR/salmon_gfp_quant_%j.out  ~/git_repos/PGTB/salmon_gfp.sh \
    -p `pwd` \
    -d /bgfs/lbyrne/PGTB/data/ \
    -n LB1_BYR819A1_S1 \
    -r /bgfs/lbyrne/PGTB/resources/gfp_barcodes_salmon_index/
```

Submit seqkit extract GFP barcodes
```
sbatch -o `pwd`/OUT_ERR/seqkit_locate_%j.out ~/git_repos/PGTB/seqkit_extract.sh \
    -p `pwd` \
    -d /bgfs/lbyrne/PGTB/data/ \
    -n LB1_BYR819A1_S1 \
    -b /bgfs/lbyrne/PGTB/resources/gfp_barcodes_25bp.fa
```

Submit in-house script to create GFP x cell matrix
```
conda activate scaavengr_env
python ~/git_repos/PGTB/gfp_cell_matrix.py \
    --bc_uniq `pwd`/analysis/salmon_quant/LB1_BYR819A1_S1_10x_bc_umi.txt \
    --gfpbc `pwd`/analysis/salmon_quant/LB1_BYR819A1_S1_R2_001.subgfp.seqkitlocate.txt \
    --out `pwd`/analysis/salmon_quant/LB1_BYR819A1_S1_gfp_cell_matrix.csv \
    --outbin `pwd`/analysis/salmon_quant/LB1_BYR819A1_S1_gfp_cell_matrix.binary.csv
```

### Analysis 

  1. Open Jupyter Notebook
       - Navigate to ondemand.htc.crc.pitt.edu
       - Interactive apps > Jupyter > launch
       - retina_explant_qc.ipynb
       - retina_explant_analysis.ipynb

Helpful single cell resources / best practices:
- https://www.sc-best-practices.org
- Best practices for single-cell across modalities, Theis et al, _Nature_, 2023 
    - https://www.nature.com/articles/s41576-023-00586-w

