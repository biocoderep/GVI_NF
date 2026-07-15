#!/bin/bash
set -e

echo "Installing GVI-NF dependencies on macOS..."
brew install seqkit mafft iqtree

# Optional: R packages
R --slave -e 'install.packages(c("ggplot2", "igraph"), repos="http://cran.r-project.org")'

echo "✓ Installation complete"
./bin/check_deps.sh
