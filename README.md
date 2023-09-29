# PGTB
Pittsburgh Gene Therapy Bootcamp 2023 (scAAVengr)


## Getting started

### Access HTC CRC

  1. If you're not on Pitt WifI:
        - Download PulseSecure VPN
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
  4. Clone scAAVengr repository
        - mkdir ${HOME}/git_repos
        - cd ${HOME}/git_repos
        - git clone <repo>

## Run scAAVengr

### Pre-processing pipeline (Part 1)

  1. Create project directory and sample metadata file
  2. Create GFP reference file
        - Submit salmon index to create indexed reference file
  3. Submit Salmon gfp quantification
  4.  Submit CellRanger


### Analysis (Part 2)

  1. Open Jupyter Notebook
       - Notebook 1: Cell type analysis
       - Notebook 2: GFPBC mapping analysis

