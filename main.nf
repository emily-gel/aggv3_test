#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { LOCUSTOBED } from "./modules/local/processes.nf"
include { BEDTOSHARD } from "./modules/local/processes.nf"
include { SHARDTORESULT } from "./modules/local/processes.nf"

workflow {

    Channel.value(params.locus).set { ch_locus }
    shard_list = Channel.fromPath("${projectDir}/resources/s3_file_paths.bed")
    sample_list = Channel.fromPath("s3://lifebit-user-data-b9a80d99-c3fc-4417-9774-850d61babe9f/deploit/teams/68c421098b6397bf4c47c9aa/users/61b077555fd1820216565b94/dataset/6908748690ba8ecbb88563db/sample_list_aggv3_01072025.csv")

    mybed = LOCUSTOBED(ch_locus)
    intersect_bed = BEDTOSHARD(mybed, shard_list)
    SHARDTORESULT(intersect_bed, sample_list)
}
