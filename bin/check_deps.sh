#!/bin/bash
set -e

echo "Checking GVI-NF dependencies..."

TOOLS=(
    "seqkit:Sequence toolkit|Install: apt-get install seqkit OR conda install seqkit"
    "mafft:Alignment tool|Install: apt-get install mafft OR conda install mafft"
    "iqtree:Phylogeny|Install: apt-get install iqtree OR conda install iqtree2"
    "beast:BEAST2 Evolutionary Analysis|Install: conda install -c bioconda beast2"
    "hyphy:HyPhy Selection Analysis|Install: conda install -c bioconda hyphy"
    "Phi:PhiPack Recombination|Install: conda install -c bioconda phipack"
    "snp-dists:SNP distance matrix|Install: conda install -c bioconda snp-dists"
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
    echo "Install via (see shell scripts in bin/):"
    echo "  - Ubuntu/Debian: bash bin/install_tools_ubuntu.sh"
    echo "  - macOS: bash bin/install_tools_macos.sh"
    echo "  - Conda (Recommended): bash bin/setup_conda.sh"
    exit 1
fi

echo ""
echo "✓ All dependencies satisfied"
exit 0
