process ANNOTATEMATPEPTIDES_NCOV {

  tag "${meta.id}"

  conda "bioconda::cyvcf=0.8.0 bioconda::gffutils=0.10.1"
  container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
    ? 'cidgoh/nf-ncov-voc-extra:0.2'
    : 'cidgoh/nf-ncov-voc-extra:0.2'}"

  input:
  tuple val(meta), path(vcf)
  tuple val(meta2), path(json)

  output:
  tuple val(meta), path("*annotated.vcf"), emit: vcf

  when:
  vcf.size() > 0

  script:

  def args = task.ext.args ?: ''
  def prefix = task.ext.prefix ?: "${meta.id}"

  """
    mature_peptide_annotation.py \\
    --vcf_file ${vcf} \\
    --json ${json} \\
    --output_vcf ${prefix}.annotated.vcf \\
    ${args}
    """
}
