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
    bedtools intersect -wo -a ${mybed} -b ${shard_list} | cut -f 1-4,9-13 > intersect.bed
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
    cut -f 11,14 ${bed_intersect} | paste
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

process VCFTOIDS { 
    debug true

    publishDir path: "temp"

    input: 
    path vcf
    path index
    val ch_locus

    output:
    path "ids.csv"

    script: 
    """
    bcftools query -r ${ch_locus} -f '[%SAMPLE\t%CHROM\t%POS\t%REF\t%ALT\t%FILTER\t%GT\n]' ${vcf}##idx##${index} | awk '$7 != "0|0"' > ids.csv
    """
}

process IDSTOSAMPLES { 
    debug true

    publishDir path: "results"

    input: 
    path id_list
    path sample_list

    output:
    path "results.csv"

    script: 
    """
    csvjoin -c ID,platekey genotypes.tsv mounted-data-readonly/sample_list_aggv3_01072025.csv | csvcut -c chrom,pos,ref,alt,genotype,ID,participant_id,type,study_source > results.csv
    """
}
