#!/usr/bin/env python

import argparse
import array
import numpy as np
import pandas as pd
import sys

################# MAIN

# GET OPTIONS
parser = argparse.ArgumentParser()
parser.add_argument('--bc_uniq')
parser.add_argument('--gfpbc')
parser.add_argument('--out')
parser.add_argument('--outbin')
args = parser.parse_args()

barcode_10x_txt = args.bc_uniq # readname to 10x bc to 10x umi
gfpbc_file = args.gfpbc # readnames to GFP barcode file
out_file = args.out
out_file_binary = args.outbin

file1 = open(gfpbc_file,"r")
gfpbc_results = file1.read().splitlines()
file1.close()


info_10x = pd.read_csv(barcode_10x_txt,header=None,sep="\t")
c_10x_barcode = dict(zip(info_10x[0],info_10x[1]))
c_umi = dict(zip(info_10x[0],info_10x[2]))
c_10xbarcode_2_virus = {}
gfp_bc_all = []
count=0
#full_10x_bc_umi_with_gfp = []

for line in gfpbc_results:
    currline = line.split("\t")
    readname = currline[0]
    gfp_bc = currline[1]
    gfp_bc_all.append(gfp_bc)
    count+=1
    # get 10x barcode based on readname
    barcode_10x = c_10x_barcode[readname]
    umi = c_umi[readname]
    #full_10x_bc_umi_with_gfp.append(fullread)
    currinfo = [umi, gfp_bc]
    if barcode_10x in c_10xbarcode_2_virus:
        # append if 10x barcode key is already present
        c_10xbarcode_2_virus[barcode_10x] = np.vstack([c_10xbarcode_2_virus[barcode_10x],currinfo])
    else:
        c_10xbarcode_2_virus[barcode_10x] = np.array(currinfo)

viral_barcode_options = np.unique(gfp_bc_all)
all_cells_df = pd.DataFrame(columns=viral_barcode_options)
all_cells_df_binary = pd.DataFrame(columns=viral_barcode_options)

for cellbarcode in np.unique(np.array(list(c_10x_barcode.values()))):
    if cellbarcode in c_10xbarcode_2_virus.keys():
        curr_array = c_10xbarcode_2_virus[cellbarcode]
        curr_array_uniq, counts = np.unique(np.atleast_2d(curr_array), axis=0, return_counts=True)
        df = pd.DataFrame(curr_array_uniq,columns=['umi','virusbarcode'])
        df['count'] = counts
        df_selected = df.sample(frac=1,random_state=1234).sort_values('count', ascending=False).groupby('umi', as_index=False).first()
        viralbarcode_arr = df_selected['virusbarcode'].to_numpy()

        # now get unique viral barcodes for this 10x cell.... run 'unique' on col2 viral barcodes
        # and get counts (# of unique UMIs) associated with viral barcode (since we know that col1 is unique)
        # append this to overall dataframe where rows=10xbarcode and the cols are the viral barcodes
        viralbarcode_uniq, viral_counts = np.unique(viralbarcode_arr, return_counts=True)
        viruses_in_10xcell = dict(zip(viralbarcode_uniq, viral_counts))
        # populate empty array for all viruses to begin with for this 10x cell
        final_viralbarcode_2_count = {key: 0 for key in viral_barcode_options}
        final_viralbarcode_2_count_binary = {key: 0 for key in viral_barcode_options}
        # then, for every unique virus that was found in this 10x cell, add count (based on # of unique umis)
        for barcode in viralbarcode_uniq:
            final_viralbarcode_2_count[barcode] = viruses_in_10xcell[barcode]
            final_viralbarcode_2_count_binary[barcode] = 1
        all_cells_df.loc[cellbarcode] = [final_viralbarcode_2_count[x] for x in final_viralbarcode_2_count.keys()]
        all_cells_df_binary.loc[cellbarcode] = [final_viralbarcode_2_count_binary[x] for x in final_viralbarcode_2_count_binary.keys()]
    else:
        all_cells_df.loc[cellbarcode] = np.zeros(len(viral_barcode_options), dtype=int)
        all_cells_df_binary.loc[cellbarcode] = np.zeros(len(viral_barcode_options), dtype=int)

# save to tsv file for future comparison with scRNAseq cell types identified by Michael
all_cells_df.to_csv(out_file)
all_cells_df_binary.to_csv(out_file_binary)
