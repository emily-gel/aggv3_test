#!/usr/bin/env python3
import click
import os
import csv
import pandas

@click.command()
@click.option( "--bed_intersect", required=True)

def shard_to_vcf (bed_intersect):

    intersect = pandas.read_table(bed_intersect, header = None)
    intersect['s3_string'] = intersect[10] + intersect[13]
    click.echo(intersect.loc[0, 's3_string'])

if __name__ == "__main__":
    shard_to_vcf()


