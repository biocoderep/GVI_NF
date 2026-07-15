process DIVERSITY {
    tag "Calculating Tajima's Pi"
    label 'process_low'

    input:
    path aligned_fasta

    output:
    path "nucleotide_diversity.json", emit: json

    script:
    """
    #!/usr/bin/env python3
    from Bio import AlignIO
    import json
    
    # Very basic implementation of Tajima's Pi for aligned fasta
    alignment = AlignIO.read("${aligned_fasta}", "fasta")
    num_seqs = len(alignment)
    
    differences = 0
    comparisons = 0
    
    if num_seqs > 1:
        # Calculate pairwise differences (simplified)
        for i in range(num_seqs):
            for j in range(i+1, num_seqs):
                seq1 = alignment[i].seq
                seq2 = alignment[j].seq
                diffs = sum(1 for a, b in zip(seq1, seq2) if a != b and a != '-' and b != '-')
                valid_len = sum(1 for a, b in zip(seq1, seq2) if a != '-' and b != '-')
                if valid_len > 0:
                    differences += diffs / valid_len
                comparisons += 1
                
        pi = differences / comparisons if comparisons > 0 else 0
    else:
        pi = 0
        
    with open('nucleotide_diversity.json', 'w') as f:
        json.dump({"tajimas_pi": pi}, f, indent=4)
    """
}
