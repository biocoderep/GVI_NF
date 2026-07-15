#!/bin/bash
# Optional: Create lightweight Conda env without locking to Docker

ENV_NAME="gvi-env"

if conda env list | grep -q "^$ENV_NAME"; then
    echo "✓ Conda environment '$ENV_NAME' already exists"
    echo "Activate: conda activate $ENV_NAME"
else
    echo "Creating lightweight Conda environment..."
    conda create -y -n $ENV_NAME \
        -c bioconda -c conda-forge \
        seqkit mafft iqtree2 paml r-base biopython beast2 hyphy phipack snp-dists
    
    echo "✓ Environment created"
    echo "Activate: conda activate $ENV_NAME"
fi
