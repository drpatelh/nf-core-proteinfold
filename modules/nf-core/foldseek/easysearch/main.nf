process FOLDSEEK_EASYSEARCH {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/foldseek:9.427df8a--pl5321hb365157_0':
        'biocontainers/foldseek:9.427df8a--pl5321hb365157_0' }"

    input:
    tuple val(meta)   , path(pdb)
    tuple val(meta_db), path(db)

    output:
    tuple val(meta), path("${meta.id}.m8"), emit: aln, optional: true
    tuple val(meta), path("${meta.id}_${meta.model.toLowerCase()}_foldseek.html"), emit: report, optional: true
    path "versions.yml"                   , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def output_file = "${prefix}.m8"
    if (args.contains("--format-mode 3")){
        output_file = "${meta.id}_${meta.model.toLowerCase()}_foldseek.html"
    }

    """
    foldseek \\
        easy-search \\
        ${pdb} \\
        ${db}/${meta_db.id} \\
        ${output_file} \\
        tmpFolder \\
        ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        foldseek: \$(foldseek --help | grep Version | sed 's/.*Version: //')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    touch ${prefix}.m8
    touch ${prefix}.html

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        foldseek: \$(foldseek --help | grep Version | sed 's/.*Version: //')
    END_VERSIONS
    """
}
