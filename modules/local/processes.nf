process LOCUSTOBED {  
    debug true

    publishDir path: "temp"

    input: 
    val locus

    output:
    path "my_region.bed"

    script: 
    """
    bed_to_shard.py --locus ${locus}
    """
}

process BEDTOSHARD { 
    debug true

    publishDir path: "temp"

    input: 
    path shard_list
    path "temp/my_region.bed"

    output:
    path "intersect.bed"

    script: 
    """
    bed_to_shard.py --mybed ${mybed} --shard_list ${shard_list}
    """
}

process SHARDTORESULT { 
    debug true

    publishDir path: "results"

    input: 
    path sample_list
    path "temp/intersect.bed"

    output:
    path "results.csv"

    script: 
    """
    shard_to_result.py --bed_intersect ${bed_intersect} --sample_list ${sample_list}
    """
}
