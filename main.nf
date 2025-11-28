#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { LOCUSTOBED } from "./modules/local/processes.nf"
include { BEDTOSHARD } from "./modules/local/processes.nf"
include { SHARDTOVCF } from "./modules/local/processes.nf"
include { GETINDEX } from "./modules/local/processes.nf"
include { VCFTOIDS } from "./modules/local/processes.nf"
include { IDSTOSAMPLES } from "./modules/local/processes.nf"

workflow {

    Channel.value(params.locus).set { ch_locus }
    Channel.fromPath(params.shards).set { shard_list }
    Channel.fromPath(params.samples).set { sample_list }

    mybed = LOCUSTOBED(ch_locus)
    bed_intersect = BEDTOSHARD(mybed, shard_list)
    vcf = SHARDTOVCF(bed_intersect)
    index = GETINDEX(vcf)
    id_list = VCFTOIDS(vcf, index, ch_locus)
    IDSTOSAMPLES(id_list, sample_list)
}
