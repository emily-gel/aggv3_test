# AggV3 workflow

This workflow takes a locus and pulls out participants with non-ref alleles within that region and identifies the source (100k/GMS/Covid) and type (rare disease, cancer, covid severity).

## Inputs required

* `--locus` in the form `chr#:start-end`
* `--shards`, the file path of the shard bed file
* `--samples`, the file path of the sample list
