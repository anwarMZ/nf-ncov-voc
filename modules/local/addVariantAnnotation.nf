process VARIANTANNOTATION {

  tag "${meta.id}"

  conda "conda-forge::pandas=1.4.3"
  container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
    ? 'https://depot.galaxyproject.org/singularity/pandas:1.4.3'
    : 'amancevice/pandas:1.4.3'}"

  input:
  tuple val(meta), path(gvf)
  tuple val(meta2), path(tsv)
  val lineage

  output:
  tuple val(meta), path("*.gvf"), emit: gvf

  script:

  def args = task.ext.args ?: ''
  def prefix = task.ext.prefix ?: "${meta.id}"
  def strain = lineage ? "--strain ${prefix}" : ''

  """
    addvariantinfo2gvf.py \\
      --ingvf ${gvf} \\
      ${strain} \\
      ${args} \\
      --outgvf ${prefix}_annotated.gvf \\
      --clades ${tsv} 
  """
}
