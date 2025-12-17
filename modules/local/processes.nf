// LOCUSTOBED converts the locus to a bed file, splitting the locus on `:` and `-` to make the bed file

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

// BEDTOSHARD intersects the bed file created in LOCUSTOBED against the shard bed file to identify the relevant shard VCF, emitting the s3 bucket string as a channel

process BEDTOSHARD { 
    debug true

    input:
    path mybed 
    path shard_list

    output:
    stdout emit: vcf_list

    script: 
    """
    bedtools intersect -wo -a ${mybed} -b ${shard_list} | awk -F '\t' '{printf "%s%s\\n", \$11, \$12}'
    """
}

// VCFTOIDS uses the original locus channel to query the vcf, the s3 location of which was found in BEDTOSHARD, and queries for variants within the locus, pulling out variant details and genotypes. The vcf needs to be input as a tuple of the vcf s3 location and the index s3 location for the bcftools query to work.

process VCFTOIDS { 
    debug true

    publishDir path: "temp"

    input: 
    tuple path(vcf), path(index)
    val ch_locus

    output:
    path "ids_${task.index}.tsv"

    script: 
    """
    bcftools query -r ${ch_locus} -f '[%SAMPLE\t%CHROM\t%POS\t%REF\t%ALT\t%FILTER\t%GT\n]' ${vcf} > ids_${task.index}.tsv
    """
}

// IDSTOSAMPLES uses the list of variants and IDs from VCFTOIDS, filters it for non-variant genotypes and combines it with the sample list from the original input, to provide details of the partcipants

process IDSTOSAMPLES { 
    debug true

    publishDir path: "results"

    input: 
    path "input_files/*"
    path sample_list

    output:
    path "results.csv"

    script: 
    """
    #!/usr/bin/env python

    import pandas as pd
    import glob

    # Loop through the files in the directory
    for input in glob.glob("input_files/*.tsv"):
        input_list = pd.read_csv(input, sep='\\t', header=None, names=['ID', 'CHROM', 'POS', 'REF', 'ALT', 'FILTER', 'GT'] , low_memory=False) 
        filtered_input = input_list[input_list['GT'] != '0/0']
        id_list = pd.concat([id_list, input_list], ignore_index=True)

    sample_list = pd.read_csv('${sample_list}', low_memory=False)
    participant_info = pd.merge(id_list, sample_list, left_on="ID", right_on="platekey")[['CHROM', 'POS', 'REF', 'ALT', 'GT', 'platekey', 'participant_id', 'type', 'study_source']]
    participant_info.to_csv('results.csv', index=False)
    """
}
