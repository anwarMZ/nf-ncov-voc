def printHelp() {
  log.info"""
  Usage:
    nextflow run main.nf -profile [singularity | docker | conda) --prefix [prefix] --mode [reference | user]  [workflow-options]

  Description:
    Variant Calling workflow for SARS-CoV-2 Variant of Concern (VOC) and
    Variant of Interest (VOI) consensus sequences to generate data
    for Visualization. All options set via CLI can be set in conf
    directory

  Nextflow arguments (single DASH):
    -profile                  Allowed values: conda & singularity

  Mandatory workflow arguments (mutually exclusive):
    --prefix                  A (unique) string prefix for output directory for each run.
    --mode                    A flag for user uploaded data through visualization app or
                              high-throughput analyses (reference | user) (Default: reference)

  Optional:

  Data options:
    --data                    Specify if the dataset is from gisaid, virusseq or custom
                              (gisaid | virusseq | custom) (Default: custom)
    --startdate               Start date (Submission date) to extract dataset
                              (yyyy-mm-dd) (Default: "None")
    --enddate                 Start date (Submission date) to extract dataset
                              (yyyy-mm-dd) (Default: "None")

  Input options:
    --seq                     Input SARS-CoV-2 genomes or consensus sequences
                              (.fasta file) (Default: $baseDir/.github/data/sequence/*.fasta)
    --meta                    Input Metadata file of SARS-CoV-2 genomes or consensus sequences
                              (.tsv file) (Default: $baseDir/.github/data/metadata/*.tsv)
    --virusseq_meta           If the
    --variants                Provide a variants file
                              (.tsv) (Default: $baseDir/.github/data/variants/variants_who.tsv)
    --input_type              Specify type of input file
                              (vcf | tsv | fasta) (Default: vcf)
    --userfile                Specify userfile
                              (fasta | tsv | vcf) (Default: None)
    --outdir                  Output directory
                              (Default: $baseDir/results)
    --gff                     Path to annotation gff for variant consequence calling and typing.
                              (Default: $baseDir/.github/data/features)

  Selection options:
    --ivar                    Run the ivar workflow
                              (Default: false, use freebayes workflow)
    --ref                     Path to SARS-CoV-2 reference fasta file
                              (Default: $baseDir/.github/data/refdb)
    --bwa                     Use BWA for mapping reads
                              (Default: false, use Minimap2)
    --bwa_index               Path to BWA index files
                              (Default: $baseDir/.github/data/refdb)

  Mapping parameters:
    --mpileupDepth            Mpileup depth (Default: unlimited)
    --var_FreqThreshold       Variant Calling frequency threshold for consensus variant
                              (Default: 0.75)
    --var_MinDepth            Minimum coverage depth to call variant
                              (ivar variants -m, freebayes -u Default: 10)
    --var_MinFreqThreshold    Minimum frequency threshold to call variant
                              (ivar variants -t, Default: 0.25)
    --varMinVariantQuality    Minimum mapQ to call variant
                              (ivar variants -q, Default: 20)

  Mapping parameters:
    --mpileupDepth            Mpileup depth (Default: unlimited)
    --var_FreqThreshold       Variant Calling frequency threshold for consensus variant
                              (Default: 0.75)
    --var_MinDepth            Minimum coverage depth to call variant
                              (ivar variants -m, freebayes -u Default: 10)
    --var_MinFreqThreshold    Minimum frequency threshold to call variant
                              (ivar variants -t, Default: 0.25)
    --varMinVariantQuality    Minimum mapQ to call variant
                              (ivar variants -q, Default: 20)
  """.stripIndent()
}