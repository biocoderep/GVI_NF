process DISTANCE {
    tag "Calculating Genetic Distance"
    label 'process_low'

    input:
    path aligned_fasta

    output:
    path "genetic_distance.json", emit: json
    path "distance_matrix.csv", emit: matrix

    script:
    """
    # Use snp-dists for a fast pairwise distance matrix
    snp-dists -c ${aligned_fasta} > distance_matrix.csv
    
    # Simple wrapper to create json
    cat > genetic_distance.json << 'EOF'
{\"status\": \"completed\", \"matrix\": \"distance_matrix.csv\"}
EOF
    """
}
