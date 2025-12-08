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
    stdout emit: vcf_channel

    script: 
    """
    bedtools intersect -wo -a ${mybed} -b ${shard_list} | awk -F '\t' 'NR==1 {printf "%s%s", \$11, \$12; exit}'
    """
}

process VCFTOIDS { 
    debug true

    publishDir path: "temp"

    input: 
    tuple path(vcf), path(index)
    val ch_locus

    output:
    path "ids.tsv"

    script: 
    """
    bcftools query -r ${ch_locus} -f '[%SAMPLE\t%CHROM\t%POS\t%REF\t%ALT\t%FILTER\t%GT\n]' ${vcf} > ids.tsv
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
    import pandas as pd

    sample_list = pd.read_csv('${sample_list}', sep='\\t', low_memory=False)
    id_list = pd.read_csv('${id_list}', sep=',')
    filtered_id = id_list[id_list['GT'] != '0/0']

    participant_info = pandas.merge(filtered_id, sample_list, left_on="ID", right_on="platekey")[['CHROM', 'POS', 'REF', 'ALT', 'GT', 'platekey', 'participant_id', 'type', 'study_source']]
    participant_info.to_csv('results.csv', index=False)
    """
}
