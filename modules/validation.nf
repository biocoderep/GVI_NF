process VALIDATION {
    tag "Validating ${input_fasta}"
    label 'process_low'

    input:
    path input_fasta

    output:
    path "validated.fasta", emit: fasta
    path "qc_report.json", emit: report

    script:
    """
    echo "Running data validation on ${input_fasta}..."
    
    # Just remove duplicates by sequence
    seqkit rmdup -s ${input_fasta} -o validated.fasta
    
    # Generate basic QC report
    cat > qc_report.json << EOF
{"status": "success", "input": "${input_fasta}"}
EOF
    """
}
