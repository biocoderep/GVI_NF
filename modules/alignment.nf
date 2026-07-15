process ALIGNMENT {
    tag "Aligning with MAFFT"
    label 'process_high'

    input:
    path input_fasta

    output:
    path "aligned.fasta", emit: aligned_fasta
    
    script:
    """
    echo "Running MAFFT alignment..."
    mafft --auto --thread ${task.cpus} ${input_fasta} > aligned.fasta
    """
}
