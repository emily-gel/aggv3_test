#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { LOCUSTOBED } from "./modules/local/processes.nf"
include { BEDTOSHARD } from "./modules/local/processes.nf"
include { VCFTOIDS } from "./modules/local/processes.nf"
include { IDSTOSAMPLES } from "./modules/local/processes.nf"

workflow {

    Channel.value(params.locus).set { ch_locus }
    Channel.fromPath(params.shards).set { shard_list }
    Channel.fromPath(params.samples).set { sample_list }

    mybed = LOCUSTOBED(ch_locus)
    vcf_channel = BEDTOSHARD(mybed, shard_list)
    vcf_tuple_channel = vcf_channel.map { s3_uri -> 
        tuple(file(s3_uri), file("${s3_uri}.tbi")) 
    }
    id_list = VCFTOIDS(vcf_tuple_channel, ch_locus)
    IDSTOSAMPLES(id_list, sample_list)
}
