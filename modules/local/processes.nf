process LOCUSTOBED {  
    debug true

    publishDir path: "temp"

    input: 
    val locus

    output:
    path "my_region.bed"

    script: 
    """
    locus_to_bed.py --locus ${locus}
    """
}

process BEDTOSHARD { 
    debug true

    publishDir path: "temp"

    input:
    path mybed 
    path shard_list

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
    path bed_intersect
    path sample_list

    output:
    path "results.csv"

    script: 
    """
    shard_to_result.py --bed_intersect ${bed_intersect}  --sample_list ${sample_list}
    """
}
