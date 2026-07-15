import os, glob, re

modules_dir = 'E:/Inlfuenza/avian_influenza/GVI_nextflow/modules'

for nf_file in glob.glob(os.path.join(modules_dir, '*.nf')):
    with open(nf_file, 'r') as f:
        content = f.read()
        
    # Remove explicit conda directives
    content = re.sub(r'^\s*conda\s+.*$\n', '', content, flags=re.MULTILINE)
    
    # Replace echo JSON with heredoc
    def replace_echo(match):
        json_content = match.group(1)
        filename = match.group(2)
        # Unescape quotes
        json_content = json_content.replace('\\"', '"')
        return f"cat > {filename} << 'EOF'\n{json_content}\nEOF"
        
    content = re.sub(r'echo\s+"({.*?})"\s+>\s+([a-zA-Z0-9_.-]+\.json)', replace_echo, content, flags=re.DOTALL)
    
    with open(nf_file, 'w') as f:
        f.write(content)

print("Heredoc refactoring and Conda removal completed.")
