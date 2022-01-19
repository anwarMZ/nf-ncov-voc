process PANGOLIN {
    //tag "$meta.id"
    //label 'process_medium'
    cpus '12'
    publishDir "${params.outdir}/${params.prefix}/${task.process.replaceAll(":","_")}", pattern: "*.csv", mode: 'copy'


    conda (params.enable_conda ? 'bioconda::pangolin=3.1.17' : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/pangolin:3.1.17--pyhdfd78af_1' :
        'quay.io/biocontainers/pangolin:3.1.17--pyhdfd78af_1' }"

    input:
    path(fasta)

    output:
    path('*.csv'), emit: report
    path  "versions.yml"          , emit: versions

    script:
    def args = task.ext.args ?: ''
    //def prefix = task.ext.prefix ?: "${meta.id}"
    """
    pangolin \\
        $fasta\\
        --outfile ${fasta.baseName}.pangolin.csv \\
        --threads $task.cpus \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pangolin: \$(pangolin --version | sed "s/pangolin //g")
    END_VERSIONS
    """
}