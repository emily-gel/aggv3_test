#!/usr/bin/env python3
import click
import os
import csv
from pybedtools import BedTool

@click.command()
@click.option( "--mybed", required=True)
@click.option( "--shard_list", required=True)

def bed_to_shard(mybed, shard_list):

    a = BedTool(mybed)
    b = BedTool(shard_list)

    a.intersect(b, wb=True).saveas('intersect.bed')


if __name__ == "__main__":
    bed_to_shard()


