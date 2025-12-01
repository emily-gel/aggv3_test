#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { LOCUSTOBED } from "./modules/local/processes.nf"
include { BEDTOSHARD } from "./modules/local/processes.nf"
include { GETINDEX } from "./modules/local/processes.nf"
include { VCFTOIDS } from "./modules/local/processes.nf"
include { IDSTOSAMPLES } from "./modules/local/processes.nf"

workflow {

    Channel.value(params.locus).set { ch_locus }
    Channel.fromPath(params.shards).set { shard_list }
    Channel.fromPath(params.samples).set { sample_list }

    mybed = LOCUSTOBED(ch_locus)
    vcf_file = BEDTOSHARD(mybed, shard_list).map { s3_uri -> file(s3_uri) }
    index_file = GETINDEX(vcf).map { s3_uri -> file(s3_uri) }
    id_list = VCFTOIDS(vcf.join(index), ch_locus)
    IDSTOSAMPLES(id_list, sample_list)
}
