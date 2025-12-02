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

    input:
    path mybed 
    path shard_list

    output:
    val vcf_channel

    script: 
    '''
    vcf_channel=bedtools intersect -wo -a ${mybed} -b ${shard_list} | awk -F '\t' '{print $11$12}'
    '''
}

process VCFTOIDS { 
    debug true

    publishDir path: "temp"

    input: 
    tuple path(vcf), path(index)
    val ch_locus

    output:
    path "ids.csv"

    script: 
    """
    bcftools query -r ${ch_locus} -f '[%SAMPLE\t%CHROM\t%POS\t%REF\t%ALT\t%FILTER\t%GT\n]' ${vcf} > ids.csv
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
    csvjoin -c ID,platekey ${id_list} ${sample_list} | csvcut -c chrom,pos,ref,alt,genotype,ID,participant_id,type,study_source > results.csv
    """
}
