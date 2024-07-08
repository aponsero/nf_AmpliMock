/*
 * Amplimock-NF Pipeline
 * This pipeline is used for generating mock amplicon sequencing data.
 */

log.info """\
    A M P L I M O C K - N F   P I P E L I N E
    ===================================
    database path               : ${params.database}
    number of taxa              : ${params.nbtax}
    output directory            : ${params.outdir}
    number of mock to generate  : ${params.nbmock}
    forward read                : ${params.fwd}
    reverse read                : ${params.rev}
    error model                 : ${params.model}
    sequencing depth            : ${params.seqdepth}
    abundance distribution      : ${params.distrib}
    """
    .stripIndent()

/* PROFILE process
 * This process generates mock profiles using the Randomizer.py script.
 */
process PROFILE {
    tag "generating mock $mockid" 

    input:
    path database
    val nbtax
    val mockid

    output:
    path "${mockid}_profile.fasta"

    script:
    """
    python3 $projectDir/scripts/Randomizer.py -f $database -t $nbtax -o ${mockid}_profile.fasta 
    """
}

/* CRABS process
 * This process runs CRABS (Cosmopolitan Robust Amplicon Bioinformatics) for in silico PCR amplification.
 */
process CRABS {
    tag "Running CRABS for $mockid" 

    input:
    path profile
    val mockid
    val primer_fw
    val primer_rev

    output:
    path "${mockid}_pcr.fa"

    script:
    """
    crabs db_import --input $profile --output ${mockid}_crabsdb.fa -s species -d "_" 
    crabs insilico_pcr --input ${mockid}_crabsdb.fa --output ${mockid}_pcr.fa --fwd $primer_fw --rev $primer_rev --error 4.5
    """
}

/* INSILICO process
 * This process runs INSILICOSEQ to generate mock amplicon sequencing data.
 */
process INSILICO {
    tag "Running INSILICOSEQ for $mockid"
    publishDir params.outdir, mode: 'copy'

    input:
    path pcr_out
    val mockid
    val model
    val seqdepth
    val distrib

    output:
    path "${mockid}_*"

    script:
    """
    iss generate --genomes $pcr_out --n_reads $seqdepth --abundance $distrib --sequence_type amplicon --model $model --output ${mockid} --compress 
    """
}

/* Main workflow */
workflow {
    mockid_ch = channel
                .from(1..params.nbmock)
                .flatMap { n -> ["mock" + n] }

    step1_ch = PROFILE(params.database, params.nbtax, mockid_ch)
    step2_ch = CRABS(step1_ch, mockid_ch, params.fwd, params.rev)
    step3_ch = INSILICO(step2_ch, mockid_ch, params.model, params.seqdepth, params.distrib)
}

/* Workflow completion message */
workflow.onComplete {
    log.info(workflow.success ? "\nDone!\n" : "Oops .. something went wrong")
}
