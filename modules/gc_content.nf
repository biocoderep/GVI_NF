process GC_CONTENT {
    tag "Calculating GC Content"
    label 'process_low'

    input:
    path input_fasta

    output:
    path "gc_results.json", emit: json

    script:
    """
    #!/usr/bin/env python3
    from Bio import SeqIO
    import json
    
    gc_percent_sum = 0
    count = 0
    
    for record in SeqIO.parse("${input_fasta}", "fasta"):
        seq = str(record.seq).upper()
        g = seq.count('G')
        c = seq.count('C')
        total = len(seq.replace('-', '').replace('N', ''))
        
        if total > 0:
            gc_percent_sum += (g + c) / total
            count += 1
            
    avg_gc = gc_percent_sum / count if count > 0 else 0
    
    results = {
        "gc_percent": avg_gc * 100,
        "gc_deviation": abs((avg_gc * 100) - 45.0) # Assume 45% baseline for example
    }
    
    with open('gc_results.json', 'w') as f:
        json.dump(results, f, indent=4)
    """
}
