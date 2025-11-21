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

process SHARDTOVCF { 
    debug true

    input: 
    path bed_intersect

    output:
    env 'vcf'

    script: 
    """
    vcf=\$(shard_to_vcf.py --bed_intersect ${bed_intersect})
    """
}

process VCFTORESULT { 
    debug true

    publishDir path: "results"

    input: 
    path vcf
    path index
    val ch_locus
    path sample_list

    output:
    path "results.csv"

    script: 
    """
    vcf_to_result.py --vcf ${vcf} --index ${index} --locus ${ch_locus}  --sample_list ${sample_list}
    """
}
