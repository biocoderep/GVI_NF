process MUTATION_BURDEN {
    tag "Calculating Mutation Burden"
    label 'process_low'

    input:
    path aligned_fasta

    output:
    path "mutation_burden.json", emit: json

    script:
    """
    #!/usr/bin/env python3
    from Bio import AlignIO
    import json
    
    alignment = AlignIO.read("${aligned_fasta}", "fasta")
    
    # Assume the first sequence is the oldest/reference sequence
    ref_seq = alignment[0].seq
    
    total_mutations = 0
    num_seqs = len(alignment)
    
    if num_seqs > 1:
        for record in alignment[1:]:
            muts = sum(1 for a, b in zip(ref_seq, record.seq) if a != b and a != '-' and b != '-')
            total_mutations += muts
            
        avg_burden = (total_mutations / (num_seqs - 1)) / (len(ref_seq) / 1000.0)
    else:
        avg_burden = 0
        
    results = {
        "mutations_per_kb": avg_burden
    }
    
    with open('mutation_burden.json', 'w') as f:
        json.dump(results, f, indent=4)
    """
}
