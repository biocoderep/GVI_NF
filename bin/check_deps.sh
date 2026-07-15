#!/bin/bash
set -e

echo "Checking GVI-NF dependencies..."

TOOLS=(
    "seqkit:Sequence toolkit|Install: apt-get install seqkit OR conda install seqkit"
    "mafft:Alignment tool|Install: apt-get install mafft OR conda install mafft"
    "iqtree:Phylogeny|Install: apt-get install iqtree OR conda install iqtree2"
)

MISSING=0

for tool_info in "${TOOLS[@]}"; do
    IFS='|' read -r tool_cmd rest <<< "$tool_info"
    IFS=':' read -r tool_name tool_desc <<< "$tool_cmd"
    
    if command -v "$tool_name" &>/dev/null; then
        VERSION=$($tool_name --version 2>/dev/null | head -1 || echo "unknown")
        echo "✓ $tool_name: $VERSION"
    else
        echo "✗ $tool_name: NOT FOUND"
        echo "  $rest"
        MISSING=$((MISSING + 1))
    fi
done

if [ $MISSING -gt 0 ]; then
    echo ""
    echo "⚠ WARNING: $MISSING tools missing"
    echo "Install via:"
    echo "  - Ubuntu/Debian: apt-get install seqkit mafft iqtree"
    echo "  - macOS (Homebrew): brew install seqkit mafft iqtree"
    echo "  - Conda: conda install -c bioconda seqkit mafft iqtree2"
    exit 1
fi

echo ""
echo "✓ All dependencies satisfied"
exit 0
