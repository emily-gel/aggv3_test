#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { LOCUSTOBED } from "./modules/local/processes.nf"
include { BEDTOSHARD } from "./modules/local/processes.nf"
include { SHARDTORESULT } from "./modules/local/processes.nf"

workflow {

    Channel.value(params.locus).set { ch_locus }
    sample_list = Channel.fromPath("${projectDir}/resources/sample_list_aggv3_01072025.csv")
    shard_list = Channel.fromPath("${projectDir}/resources/s3_file_paths.bed")

    mybed = LOCUSTOBED(ch_locus)
    intersect_bed = BEDTOSHARD(mybed, shard_list)
    SHARDTORESULT(bed_intersect, sample_list)
}



// Default parameter input
params.str = "Hello world!"

// split process
process split {
    publishDir "results/lower"
    
    input:
    val x
    
    output:
    path 'chunk_*'

    script:
    """
    printf '${x}' | split -b 6 - chunk_
    """
}

// convert_to_upper process
process convert_to_upper {
    publishDir "results/upper"
    tag "$y"

    input:
    path y

    output:
    path 'upper_*'

    script:
    """
    cat $y | tr '[a-z]' '[A-Z]' > upper_${y}
    """
}

// Workflow block
workflow {
    ch_str = channel.of(params.str)       // Create a channel using parameter input
    ch_chunks = split(ch_str)             // Split string into chunks and create a named channel
    convert_to_upper(ch_chunks.flatten()) // Convert lowercase letters to uppercase letters
}