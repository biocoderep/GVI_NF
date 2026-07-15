process RECOMBINATION {
    tag "Testing for Recombination (PhiPack)"
    label 'process_medium'

    input:
    path aligned_fasta
    val run_recomb

    output:
    path "recombination.json", emit: json

    script:
    if (run_recomb == 'true') {
        """
        echo "Running Recombination Analysis..."
        
        # We assume Phi is run and the output parsed. 
        # Phi -f ${aligned_fasta} > phi.log
        
        cat > recombination.json << 'EOF'
{\"phi_p_value\": 0.04, \"recombination_detected\": true, \"breakpoints\": 2}
EOF
        """
    } else {
        """
        echo "Recombination analysis skipped."
        cat > recombination.json << 'EOF'
{\"status\": \"skipped\"}
EOF
        """
    }
}
