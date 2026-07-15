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
    r-base

echo "✓ Installation complete"
./bin/check_deps.sh
