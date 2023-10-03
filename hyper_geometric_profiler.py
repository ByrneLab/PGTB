import numpy as np
import pandas as pd
from typing import Dict
from scipy import stats
from collections import defaultdict
import csv
import scanpy as sc
from anndata import AnnData


def reverse_dict(forw):
    rev = {}
    for key in forw:
        for val in forw[key]:
            rev[val] = key
    return rev

class Local_Profiler:
    def __init__(self,fname:str,ftype="enrichr"):
        if ftype=="enrichr":
            self.read_in_csv(fname)
        elif ftype=="cellmarker":
            self.read_in_cellmarker_csv(fname)
        elif ftype=="retina":
            self.read_in_retina(fname)

    def read_in_csv(self,fname:str):
        self.go_dict = defaultdict(set)
        with open(fname,'r') as csv_file:
            reader = csv.reader(csv_file,delimiter="\t")
            next(reader)
            for row in reader:
                cat = row[0]
                genes = [part.split(",")[0] for part in row[2:len(row)-1]]
                self.go_dict[cat].update(genes)

    def read_in_retina(self,fname:str):
        self.go_dict = defaultdict(set)
        with open(fname,'r') as csv_file:
            reader = csv.reader(csv_file)
            next(reader)
            for row in reader:
                cell_type = row[0]
                genes = row[2:]
                genes_fixed = set([gene.strip().lower().capitalize() for gene in genes])
                self.go_dict[cell_type] = genes_fixed

    def read_in_cellmarker_csv(self,fname:str):
        self.go_dict = defaultdict(set)
        with open(fname,'r') as csv_file:
            reader = csv.reader(csv_file, delimiter="\t")
            next(reader)
            for row in reader:
                genes,cat = row[6].split(", "),row[0]+" "+row[4]
                genes = [gene.lower().capitalize() for gene in genes]
                self.go_dict[cat].update(genes)

    def local_profiler_results(self,genes,p_val_thresh,all_genes):
        gene_set = set(genes)
        all_gene_set = set(all_genes)
        pvals = []
        go_terms = []
        genes_found = []
        for go in self.go_dict:
            inter = gene_set.intersection(self.go_dict[go])
            all_inter = all_gene_set.intersection(self.go_dict[go])
            pval = stats.hypergeom.sf(len(inter)-1,len(all_gene_set),len(all_inter),len(gene_set))*len(self.go_dict)
            if pval< p_val_thresh and len(inter)>0:
                pvals.append(pval)
                go_terms.append(go)
                genes_found.append(','.join(inter))
                #results.append((pval,go, ', '.join(inter)))
        result_dict= {"p_value": pvals, "label": go_terms, "query_match": genes_found}
        return pd.DataFrame(result_dict)


    def label_cell_types(self,ann_data , cluster_list, p_value_thresh):
        cell_type_dict ={}
        gene_names = ann_data.var_names
        uniq_clusts = np.unique(np.asarray(cluster_list))
        for selected_clust in uniq_clusts:
            is_mark = [clust == selected_clust for clust in cluster_list]
            ann_data.obs["mark"] = pd.Categorical(
                values=is_mark,
                categories=[True, False])
            sc.tl.rank_genes_groups(ann_data, "mark")
            m_genes = [tup[0] for tup in ann_data.uns["rank_genes_groups"]["names"]][:50]
            marker_genes = [gene.lower().capitalize() for gene in m_genes]
            to_print = "CLUSTER: " + str(selected_clust)
            print(to_print)
            print("------------------------------------------------------------------------------")
            re_df = self.local_profiler_results(marker_genes, p_value_thresh, gene_names)
            print(re_df)
            if re_df.empty:
                cell_type_dict[selected_clust] = selected_clust
            else:
                cell_type_dict[selected_clust] = re_df["label"].values[np.argmin(re_df["p_value"].values)]
        return cell_type_dict

