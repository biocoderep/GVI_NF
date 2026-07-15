process PHYLOGENY {
    tag "Building tree with IQ-TREE"
    label 'process_high'

    input:
    path aligned_fasta

    output:
    path "${aligned_fasta}.treefile", emit: tree
    path "${aligned_fasta}.iqtree", emit: report

    script:
    """
    echo "Running IQ-TREE..."
    IQTREE_CMD=\$(command -v iqtree2 || command -v iqtree || echo "iqtree2")
    \${IQTREE_CMD} -s ${aligned_fasta} -T ${task.cpus} -B 1000 -m TEST
    """
}
