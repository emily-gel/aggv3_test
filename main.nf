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

    // convert input locus to bed
    mybed = LOCUSTOBED(ch_locus)

    // identify s3 locus of the relevant shard VCF
    vcf_list = BEDTOSHARD(mybed, shard_list)

    vcf_channel = getMatches.out.vcf_list.splitText() { it.trim() }

    // find the location of the index file and create a tuple of the VCF channel and index channel
    vcf_tuple_channel = vcf_channel.map { s3_uri -> 
        tuple(file(s3_uri), file("${s3_uri}.tbi")) 
    }

    // query the VCF for all variants within the region
    id_list = VCFTOIDS(vcf_tuple_channel, ch_locus)

    // filter the participants for variant genotypes and query for participant details
    IDSTOSAMPLES(id_list, sample_list)
}
