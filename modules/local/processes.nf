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
    echo '${locus}\tlocus' | tr :- '\t' > my_region.bed
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
    cut -f 10,13 ${bed_intersect} | paste
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
    bcftools query -r ${ch_locus} -f '[%SAMPLE\t%CHROM\t%POS\t%REF\t%ALT\t%FILTER\t%GT\n]' ${vcf}##idx##${index} > results.csv
    """
}
