#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Dec  2 12:49:47 2021

@author: madeline
"""


import argparse
import pandas as pd
import os


def parse_args():
    
    parser = argparse.ArgumentParser(
        description='Creates two dataframes from a surveillance report TSV')
    parser.add_argument('--tsv', type=str, default=None,
                        help='Path to surveillance report TSV file')
    parser.add_argument('--functions_table', type=str, default=None,
                        help='TSV file containing Pokay category:NML category mappings')
    parser.add_argument('--frequency_threshold', type=float, default=0.2,
                        help='Alternate frequency threshold cutoff for inclusion in report')

    return parser.parse_args()


def make_functions_df(tsv, functions_df_template):
    

    #load functions_df template
    functions_df = pd.read_csv(functions_df_template, sep='\t', header=0)
    
    #populate the Mutations column row by row
    for row in functions_df['Sub-categories from POKAY']:
        row_mutations_set = set()
        category_list = row.split(',') #get list of Pokay categories
        for category in category_list:
            category = category.rstrip() #remove trailing spaces to enable matching
            #find mutation names that match that category and add them to the set
            cat_mutations = tsv[tsv['function_category']==category]['name']
            cat_mutations_set = set(cat_mutations)
            #add category mutations set to row mutations set
            row_mutations_set.update(cat_mutations_set)
        #save row mutations set in the 'Mutations' column, sorted alphabetically
        row_list = sorted(list(row_mutations_set))
        row_str = ', '.join(str(e) for e in row_list)
        mask = functions_df['Sub-categories from POKAY']==row
        functions_df.loc[mask, 'Mutations'] = row_str
    
    return functions_df


def make_mutations_df(tsv, functions_dataframe):
    
    named_mutations = functions_dataframe['Mutations'].values.tolist()
    named_mutations = ', '.join(str(e) for e in named_mutations).split(', ')
    named_mutations = set(named_mutations)
    named_mutations.remove('')
        
    #tsv columns to use
    tsv_df_cols = ['name', 'function_category', 'function_description', 'viral_clade_defining', 'citation', 'ao', 'dp', 'Frequency (Variant)']

    #create empty dataframe
    mutations_df = pd.DataFrame(columns=tsv_df_cols)


    for mutation in named_mutations:
        #get rows of the tsv for that mutation
        tsv_rows = tsv[tsv['name']==mutation]
        #keep certain columns of the tsv rows
        tsv_rows = tsv_rows[tsv_df_cols]
        #concatenate dfs
        mutations_df = pd.concat((mutations_df, tsv_rows))
    
    #remove clade-defining values from strains column
    mutations_df['viral_clade_defining'] = mutations_df['viral_clade_defining'].str.replace(r"=.*?;",",", regex=True)
    #remove trailing commas
    mutations_df['viral_clade_defining'] = mutations_df['viral_clade_defining'].str.rstrip(' ').str.rstrip(',')
    
    #rename mutations_df columns
    final_mutations_df_cols = ['Mutations', 'Sub-category', 'Function', 'Lineages', 'Citation', 'ao', 'dp', 'Frequency (Variant)']
    renaming_dict = dict(zip(tsv_df_cols, final_mutations_df_cols))
    mutations_df = mutations_df.rename(columns=renaming_dict)
        
    #add 'Frequency (Functional)' column
    mutations_df['Frequency (Functional)'] = mutations_df['ao'] / mutations_df['dp']  # ao / dp
    
    #reorder mutations_df columns
    mutations_df_cols = ['Mutations', 'Frequency (Variant)', 'Frequency (Functional)', 'Sub-category', 'Function', 'Lineages', 'Citation']
    mutations_df = mutations_df[mutations_df_cols]

    return mutations_df


        
if __name__ == '__main__':
    
    args = parse_args()
    functions_table = args.functions_table
    report_tsv = args.tsv
    
    #load tsv and remove all rows that don't meet the frequency cutoff
    tsv_df = pd.read_csv(args.tsv, sep='\t', header=0) 

    #add 'Frequency (Variant)' row
    if tsv_df['ao'][tsv_df['ao'].astype(str).str.contains(",")].empty: #if there are no commas anywhere in the 'ao' column, calculate AF straight out
        tsv_df['Frequency (Variant)'] = tsv_df['ao'].astype(int) / tsv_df['obs_sample_size'].astype(int)
    else: #if there is a comma, add the numbers together to calculate alternate frequency
        tsv_df['added_ao'] = tsv_df['ao'].apply(lambda x: sum(map(int, x.split(','))))
        tsv_df['Frequency (Variant)'] =  tsv_df['added_ao'].astype(int) / tsv_df['obs_sample_size'].astype(int)
    #remove rows where frequency < threshold
    mask = tsv_df['Frequency (Variant)'] >= args.frequency_threshold
    tsv_df = tsv_df[mask]

    #make functions_df
    functions_df = make_functions_df(tsv_df, functions_table)
    #functions_df.to_csv('functions.tsv', sep='\t', index=False)
    
    #make mutations_df
    mutations_df = make_mutations_df(tsv_df, functions_df)
    #mutations_df.to_csv('mutations.tsv', sep='\t', index=False)