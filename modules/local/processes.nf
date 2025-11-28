process LOCUSTOBED {  
    debug true

    publishDir path: "temp"

    input: 
    val locus

    output:
    path "my_region.bed"

    script: 
    """
    touch my_region.bed
    echo ${locus} | tr :- '\t'  > my_region.bed
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
    bedtools intersect -wo -a ${mybed} -b ${shard_list} | cut -f 1-3,9-13 > intersect.bed
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
    awk -F'\t' '{print $10,$13}' ${bed_intersect}
    """
}

process GETINDEX {
    debug true

    input:
    env vcf

    output:
    env 'index'

    script:
    """
    index=\${vcf}.tbi
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
