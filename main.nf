#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { LOCUSTOBED } from "./modules/local/processes.nf"
include { BEDTOSHARD } from "./modules/local/processes.nf"
include { SHARDTORESULT } from "./modules/local/processes.nf"

workflow {

    Channel.value(params.locus).set { ch_locus }
    sample_list = Channel.fromPath("${projectDir}/resources/sample_list_aggv3_01072025.csv")
#    shard_list = Channel.fromPath("${projectDir}/resources/s3_file_paths.bed")

    mybed = LOCUSTOBED(ch_locus)
    intersect_bed = BEDTOSHARD(mybed, shard_list)
    SHARDTORESULT(bed_intersect)
}
