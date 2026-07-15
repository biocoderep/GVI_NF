# GVI-NF Installation Guide

## Quick Start (Any System)

### Option 1: Conda (Recommended - Isolated Environment)
```bash
# Install Conda/Miniconda if needed
curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh
bash miniconda.sh

# Clone pipeline
git clone <your-repo> gvi-nf && cd gvi-nf

# Setup environment (auto-installs all tools)
bash bin/setup_conda.sh
conda activate gvi-env

# Run
nextflow run main.nf --input data.fasta
```

### Option 2: Ubuntu/Debian (System-Wide)
```bash
# Install dependencies system-wide
sudo bash bin/install_tools_ubuntu.sh

# Clone pipeline
git clone <your-repo> gvi-nf && cd gvi-nf

# Run
nextflow run main.nf --input data.fasta
```

### Option 3: macOS (Homebrew)
```bash
# Install Homebrew if needed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
bash bin/install_tools_macos.sh

# Clone pipeline
git clone <your-repo> gvi-nf && cd gvi-nf

# Run
nextflow run main.nf --input data.fasta
```

### Option 4: Manual Installation (Advanced)
- Install tools manually using your system's package manager
- Run: `bash bin/check_deps.sh` to verify
- Run: `nextflow run main.nf --input data.fasta`

## Platform-Specific Notes

**Linux:**
- Use: `apt-get` (Debian/Ubuntu), `yum` (CentOS/RHEL), `pacman` (Arch)
- Or: Conda (works everywhere)

**macOS:**
- Recommended: Homebrew
- Alternative: Conda

**Windows:**
- WSL2 (Windows Subsystem for Linux) + Ubuntu
- Or: Conda (Windows native, but WSL2 preferred for bioinformatics)

**HPC Clusters:**
- Use `-profile slurm` (SLURM clusters)
- Use `-profile lsf` (LSF clusters)
- Module system: `module load <tool>` before running
