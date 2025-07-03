process STAR_FUSION {

    tag "$meta.id"

    label 'process_high'
    
    input:
    tuple val(meta), path(fastq_1), path(fastq_2), path(junction)
    path reference

    output:
    tuple val(meta), path("*.fusion_predictions.tsv")                   , emit: fusions
    tuple val(meta), path("*.abridged.tsv")                             , emit: abridged
    tuple val(meta), path("*.coding_effect.tsv")     , optional: true   , emit: coding_effect
    path "versions.yml"                                                 , emit: versions
    
    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def args = task.ext.args ?: ''

    """
    STAR-Fusion \\
        --genome_lib_dir ${reference} \\
        --left_fq ${fastq_1} \\
        --right_fq ${fastq_2} \\
        -J ${junction} \\
        --CPU ${task.cpus} \\
        --examine_coding_effect \\
        --extract_fusion_reads \\
        --output_dir . \\
        --FusionInspector inspect \\
        $args
    
    mv star-fusion.fusion_predictions.tsv ${prefix}.starfusion.fusion_predictions.tsv
    mv star-fusion.fusion_predictions.abridged.tsv ${prefix}.starfusion.abridged.tsv
    mv star-fusion.fusion_predictions.abridged.coding_effect.tsv ${prefix}.starfusion.abridged.coding_effect.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        STAR-Fusion: \$(STAR-Fusion --version 2>&1 | grep -i 'version' | sed 's/STAR-Fusion version: //')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.starfusion.fusion_predictions.tsv
    touch ${prefix}.starfusion.abridged.tsv
    touch ${prefix}.starfusion.abridged.coding_effect.tsv
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        STAR-Fusion: \$(STAR-Fusion --version 2>&1 | grep -i 'version' | sed 's/STAR-Fusion version: //')
    END_VERSIONS
    """
}
