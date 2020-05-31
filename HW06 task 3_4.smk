config = dict(
    paths={
        'cond1': "reads/A.fq.gz",
        'input': "reads/B.fq.gz"
    },
    mem_gb=dict(cond1 = 10)
)

rule all:
    input: "bams/cond1.bam"

def align_input_function(wildcards):
    paths = config['paths']

    sample_path = paths[wildcards.sample]

    if 'input' in paths:
        return dict(fq=sample_path, input=paths['input'])
    else:
        return [sample_path]

rule align:
    input: unpack(align_input_function)
    output: touch("bams/{sample}.bam")
    threads: 10
    params:
        mem = lambda wildcards, threads: str(threads * config["paths"][wildcards.sample]) + 'gb', # correct
        basename = "bams/{sample}" # output file path without '.bam' suffix
    run:
        if not input.get('input'):
            shell('echo "tool --mem {params.mem} {input} {params.basename}" ')
        else:
            shell('echo "tool --mem {params.mem}  --input {input.input} {input.fq} {params.basename}" ')
