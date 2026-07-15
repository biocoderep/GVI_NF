process SELECTION {
    tag "HyPhy Selection (dN/dS)"
    label 'process_high'

    input:
    path aligned_fasta
    path treefile
    val mode

    output:
    path "selection_results.json", emit: json

    script:
    """
    echo "Running HyPhy \${mode} for site-specific selection..."
    # Lowercase the mode for hyphy command since it expects slac, fel, busted
    MODE_LOWER=\$(echo "\${mode}" | tr '[:upper:]' '[:lower:]')
    
    hyphy \${MODE_LOWER} --alignment ${aligned_fasta} --tree ${treefile} --output selection_results.json
    """
}
