#!/usr/bin/env python3
import click
import os
import csv
import pandas
from pysam import VariantFile


@click.command()
@click.option( "--vcf", required=True)
@click.option( "--sample_list", required=True)

def vcf_to_result (vcf, sample_list):

    shard_vcf = VariantFile(vcf) 

    filtered = shard_vcf.fetch(locus.split(":")[0], int(locus.split(":")[1].split("-")[0]), int(locus.split(":")[1].split("-")[1]))
    rows = pandas.DataFrame(columns=['chrom', 'pos', 'ref', 'alt', 'ID', 'genotype'])

    for rec in filtered:
        for sample_name, sample_data in rec.samples.items():
            if sample_data['GT'] != (0,0) :
                row = [rec.chrom, rec.pos, rec.ref, rec.alts, sample_name, sample_data['GT']]
                rows.loc[len(rows)] = row

    sample_list = pandas.read_table(sample_list, sep=",", low_memory=False)
    participant_info = pandas.merge(rows, sample_list, left_on="ID", right_on="platekey")[['chrom', 'pos', 'ref', 'alt', 'genotype', 'platekey', 'participant_id', 'type', 'study_source']]
    rows.to_csv('results.csv', index=False)

if __name__ == "__main__":
    vcf_to_result()
