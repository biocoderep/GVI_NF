#!/bin/bash
set -e

echo "Installing GVI-NF dependencies on Ubuntu/Debian..."
sudo apt-get update
sudo apt-get install -y \
    seqkit \
    mafft \
    iqtree \
    paml \
    python3-biopython \
    r-base \
    hyphy-mpi \
    snp-dists \
    phipack
    
echo "Note: BEAST2 is typically not available in default apt repositories. It is highly recommended to install it via Conda (bin/setup_conda.sh) or manually."

echo "✓ Installation complete"
./bin/check_deps.sh
