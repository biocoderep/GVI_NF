#!/usr/bin/env python3

import os
import sys
import subprocess

try:
    import psutil
    HAS_PSUTIL = True
except ImportError:
    HAS_PSUTIL = False

def clear_screen():
    os.system('cls' if os.name == 'nt' else 'clear')

def get_hardware_info():
    cpus = os.cpu_count() or 4
    if HAS_PSUTIL:
        mem_bytes = psutil.virtual_memory().total
        mem_gb = int(mem_bytes / (1024 ** 3))
    else:
        mem_gb = 16 # Fallback if psutil is missing
    return cpus, mem_gb

def to_wsl_path(win_path):
    if not win_path or os.name != 'nt': 
        return win_path
    if ":" in win_path:
        drive, rest = win_path.split(":", 1)
        win_path = f"/mnt/{drive.lower()}{rest.replace(chr(92), '/')}"
    return win_path.replace(chr(92), '/')

def check_nextflow():
    base_cmd = ["wsl"] if os.name == 'nt' else []
    
    # 1. Check global nextflow
    try:
        subprocess.run(base_cmd + ["nextflow", "-v"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True, shell=(os.name == 'nt'))
        return "nextflow"
    except (subprocess.CalledProcessError, FileNotFoundError):
        pass
        
    # 2. Check local nextflow in current dir
    local_nf = "./nextflow"
    try:
        subprocess.run(base_cmd + [local_nf, "-v"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True, shell=(os.name == 'nt'))
        return local_nf
    except (subprocess.CalledProcessError, FileNotFoundError):
        pass
        
    # 3. Install locally if missing
    print("\\n[!] Nextflow not found. Attempting to install it locally...")
    try:
        install_cmd = base_cmd + ["bash", "-c", "curl -s https://get.nextflow.io | bash"]
        subprocess.run(install_cmd, check=True, shell=(os.name == 'nt'))
        print("[+] Nextflow installed successfully!")
        return local_nf
    except Exception as e:
        print(f"[-] Failed to automatically install Nextflow: {e}")
        print("Please ensure Java (JRE 11+) and curl are installed, or install Nextflow manually.")
        sys.exit(1)

def prompt(question, options=None, default=None):
    if options:
        print(f"\n{question}")
        for i, opt in enumerate(options, 1):
            print(f"{i}. {opt}")
        while True:
            choice = input("\n> ")
            if choice.isdigit() and 1 <= int(choice) <= len(options):
                return options[int(choice) - 1]
            print("Invalid choice, try again.")
    else:
        while True:
            if default:
                choice = input(f"\n{question} [Default: {default}]\n> ")
                if not choice.strip():
                    return default
                return choice
            else:
                choice = input(f"\n{question}\n> ")
                if choice.strip():
                    return choice
                print("Input cannot be empty.")

def prompt_yes_no(question, default="Y"):
    while True:
        choice = input(f"\n{question} [Y/N] [Default: {default}]\n> ").upper()
        if not choice.strip():
            choice = default
        if choice in ['Y', 'N']:
            return choice == 'Y'
        print("Please enter Y or N.")

def main():
    clear_screen()
    print("======================================================")
    print("GVI-NF : Genomic Vulnerability Index Pipeline Wizard")
    print("======================================================")
    
    cpus, mem_gb = get_hardware_info()
    print(f"\nDetected CPUs : {cpus}")
    print(f"Detected RAM  : {mem_gb} GB")
    
    input_file = prompt("Enter path to input FASTA file:")
    
    genome_type = prompt("Select Genome Type", ["RNA Virus", "DNA Virus"])
    
    is_segmented = False
    if genome_type == "RNA Virus":
        is_segmented = prompt("Is the virus segmented?", ["Yes", "No"]) == "Yes"
        
    host_species = prompt("Host Species", 
        ["Human", "Chicken", "Duck", "Turkey", "Pig", "Cattle", "Sheep", "Goat", "Custom"])
    if host_species == "Custom":
        host_species = prompt("Enter Custom Host Name:")
        
    virus_name = prompt("Virus Name (e.g., Avian Influenza):")
    
    serotype = "Unknown"
    if prompt_yes_no("Known Serotype?", "N"):
        serotype = prompt("Enter Serotype:")
        
    selection_mode = prompt("Selection Pressure Mode (HyPhy)", ["SLAC (Fast)", "FEL (Standard)", "BUSTED (Advanced)"]).split()[0]
        
    run_recomb = prompt_yes_no("Run Recombination Analysis?", "N")
    run_evo = prompt_yes_no("Run Evolutionary Rate Analysis?", "N")
    run_re = prompt_yes_no("Run Re Estimation?", "N")
    
    out_format = prompt("Output Format", ["HTML", "PDF", "JSON", "All"])
    
    threads = prompt("Threads to use?", default=str(max(1, cpus - 2)))
    memory = prompt("Memory to allocate?", default=f"{max(1, mem_gb - 2)}.GB")
    
    print("\n======================================================")
    print("Review Configuration:")
    print(f"Input: {input_file}")
    print(f"Genome: {genome_type}")
    print(f"Host: {host_species}")
    print(f"Virus: {virus_name} (Serotype: {serotype})")
    print(f"Resources: {threads} threads, {memory}")
    
    if not prompt_yes_no("Launch Analysis?", "Y"):
        print("Aborted.")
        sys.exit(0)
        
    # Translate path for WSL if on Windows
    nf_input = to_wsl_path(input_file)
        
    # Check and Auto-Install Nextflow
    nf_cmd = check_nextflow()
    
    # Construct Nextflow command
    cmd = []
    if os.name == 'nt':
        cmd.append("wsl")
        
    cmd.extend([
        nf_cmd, "run", "main.nf",
        "--input", nf_input,
        "--genome_type", genome_type.split()[0],
        "--is_segmented", str(is_segmented).lower(),
        "--host_species", host_species,
        "--serotype", serotype,
        "--selection_mode", selection_mode,
        "--run_recomb", str(run_recomb).lower(),
        "--run_evo_rate", str(run_evo).lower(),
        "--run_re", str(run_re).lower(),
        "--output_format", out_format,
        "--threads", threads,
        "--memory", memory
    ])
    
    cmd_str = " ".join(cmd)
    print(f"\nExecuting:\n{cmd_str}")
    
    # Run the command
    try:
        # Use shell=True on Windows to resolve commands like .bat or .cmd files
        subprocess.run(cmd_str if os.name == 'nt' else cmd, check=True, shell=(os.name == 'nt'))
    except subprocess.CalledProcessError as e:
        print(f"\nPipeline failed with exit code {e.returncode}")
        sys.exit(e.returncode)

if __name__ == "__main__":
    main()
