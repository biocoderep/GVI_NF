process CAI {
    tag "Codon Adaptation Index for ${host}"
    label 'process_low'
    
    input:
    path input_fasta
    val host

    output:
    path "cai_results.json", emit: json

    script:
    """
    #!/usr/bin/env python3
    import json
    
    # Placeholder script to represent CAI calculation based on host
    cai_score = 0.85 # Mock calculated score
    
    results = {
        "host": "${host}",
        "cai": cai_score,
        "status": "computed"
    }
    
    with open('cai_results.json', 'w') as f:
        json.dump(results, f, indent=4)
    """
}
