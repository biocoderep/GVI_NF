#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*
 * =========================================================================
 * GVI-NF : Genomic Vulnerability Index Pipeline
 * =========================================================================
 */

// Include modules FIRST
include { VALIDATION } from './modules/validation'
include { ALIGNMENT } from './modules/alignment'
include { PHYLOGENY } from './modules/phylogeny'
include { DIVERSITY } from './modules/diversity'
include { DISTANCE } from './modules/distance'
include { SELECTION } from './modules/selection'
include { CAI } from './modules/cai'
include { GC_CONTENT } from './modules/gc_content'
include { MUTATION_BURDEN } from './modules/mutation_burden'
include { TEMPORAL_SIGNAL } from './modules/temporal_signal'
include { EVOLUTIONARY_RATE } from './modules/evolutionary_rate'
include { RE_ESTIMATION } from './modules/re_estimation'
include { RECOMBINATION } from './modules/recombination'
include { GVI_SCORING } from './modules/gvi_scoring'

def printHeader() {
    log.info """\\
    ======================================================
    GVI-NF : Genomic Vulnerability Index v1.1
    System: ${System.getProperty("os.name")} ${System.getProperty("os.version")}
    Java: ${System.getProperty("java.version")}
    Nextflow: ${nextflow.version}
    ======================================================
    input        : ${params.input}
    genome_type  : ${params.genome_type}
    is_segmented : ${params.is_segmented}
    host         : ${params.host_species}
    serotype     : ${params.serotype}
    outdir       : ${params.outdir}
    threads      : ${params.threads}
    memory       : ${params.memory}
    ======================================================
    """.stripIndent()
}

workflow {
    printHeader()
    
    // Input validation (system-agnostic)
    if (!params.input) {
        log.error "ERROR: --input parameter required"
        log.error "Usage: nextflow run main.nf --input sequence.fasta [options]"
        exit 1
    }
    
    input_file = file(params.input)
    if (!input_file.exists()) {
        log.error "ERROR: Input file not found: ${params.input}"
        exit 1
    }
    
    log.info "System Profile: ${workflow.profile ?: 'default (local)'}"
    log.info "Available CPUs: ${Runtime.getRuntime().availableProcessors()}"
    log.info "Available Memory: ${Runtime.getRuntime().totalMemory() / (1024**3).toInteger()} GB"
    
    // 1. Channel setup
    ch_input = input_file
    
    // 2. Data Validation
    ch_validated = VALIDATION(ch_input)
    
    // 3. Alignment
    ch_aligned = ALIGNMENT(ch_validated.fasta)
    
    // 4. Phylogeny
    ch_tree = PHYLOGENY(ch_aligned.aligned_fasta)
    
    // 5. Evolutionary Metrics (Phase 2)
    ch_diversity = DIVERSITY(ch_aligned.aligned_fasta)
    ch_distance = DISTANCE(ch_aligned.aligned_fasta)
    ch_selection = SELECTION(ch_aligned.aligned_fasta, ch_tree.tree, params.selection_mode)
    ch_cai = CAI(ch_validated.fasta, params.host_species)
    ch_gc = GC_CONTENT(ch_validated.fasta)
    ch_mutation = MUTATION_BURDEN(ch_aligned.aligned_fasta)
    
    // 6. BEAST2 & Recombination (Phase 3)
    ch_temporal = TEMPORAL_SIGNAL(ch_tree.tree, ch_aligned.aligned_fasta)
    ch_evo_rate = EVOLUTIONARY_RATE(ch_aligned.aligned_fasta, params.run_evo_rate)
    ch_re = RE_ESTIMATION(ch_aligned.aligned_fasta, params.run_re)
    ch_recomb = RECOMBINATION(ch_aligned.aligned_fasta, params.run_recomb)
    
    // 7. Final GVI Scoring
    ch_gvi = GVI_SCORING(
        ch_diversity.json,
        ch_distance.json,
        ch_selection.json,
        ch_cai.json,
        ch_gc.json,
        ch_mutation.json,
        ch_temporal.json,
        ch_evo_rate.json,
        ch_re.json,
        ch_recomb.json
    )
    
    log.info "Pipeline execution complete (Phase 3 Final GVI Scoring)."
}
