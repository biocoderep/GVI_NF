import os, glob, re
modules_dir = 'E:/Inlfuenza/avian_influenza/GVI_nextflow/modules'
mapping = {
    'validation': 'validation',
    'alignment': 'alignment',
    'phylogeny': 'phylogeny',
    'cai': 'scoring',
    'gc_content': 'scoring',
    'mutation_burden': 'scoring',
    'gvi_scoring': 'scoring',
    'diversity': 'evolution',
    'distance': 'evolution',
    'selection': 'evolution',
    'temporal_signal': 'evolution',
    'evolutionary_rate': 'evolution',
    're_estimation': 'evolution',
    'recombination': 'evolution'
}

for nf_file in glob.glob(os.path.join(modules_dir, '*.nf')):
    mod_name = os.path.basename(nf_file).replace('.nf', '')
    yaml_name = mapping.get(mod_name, 'scoring')
    
    with open(nf_file, 'r') as f:
        content = f.read()
        
    # Replace conda '...' with conda "${projectDir}/envs/NAME.yml"
    new_content = re.sub(r"conda\s+'.*?'", f'conda "${{projectDir}}/envs/{yaml_name}.yml"', content)
    
    with open(nf_file, 'w') as f:
        f.write(new_content)
        
print('Successfully refactored modules to use conda YAMLs!')
