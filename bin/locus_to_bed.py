#!/usr/bin/env python3
import click
import os
import csv

@click.command()
@click.option( "--locus", required=True)

def locus_to_bed(locus):

    bed = locus.split(":")[0], locus.split(":")[1].split("-")[0], locus.split(":")[1].split("-")[1], "locus"
    with open('my_region.bed', 'w', newline='') as f_output:
        tsv_output = csv.writer(f_output, delimiter='\t')
        tsv_output.writerow(bed)


if __name__ == "__main__":
    locus_to_bed()
