#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// import modules

include { SNPEFF               } from '../modules/local/snpeff'
include { tagProblematicSites  } from '../modules/local/custom'
include { annotate_mat_peptide } from '../modules/local/custom'
include { vcfTogvf             } from '../modules/local/custom'


workflow annotation {
    take:
      ch_vcf
      ch_probvcf
      ch_geneannot
      ch_funcannot
      ch_genecoord
      ch_mutationsplit
      ch_variant
      ch_stats

    main:


      tagProblematicSites(ch_vcf.combine(ch_probvcf))
      SNPEFF(tagProblematicSites.out.filtered_vcf)
      annotate_mat_peptide(SNPEFF.out.peptide_vcf.combine(ch_geneannot))
      ch_annotated_vcf=annotate_mat_peptide.out.annotated_vcf
      vcfTogvf(ch_annotated_vcf, ch_funcannot.combine(ch_genecoord).combine(ch_mutationsplit).combine(ch_variant), ch_stats)
      if(!params.mode == 'user'){
          ch_gvf=vcfTogvf.out.gvf.collect()
      }
      else{
        ch_gvf=vcfTogvf.out.gvf
      }


    emit:
      ch_gvf
      ch_stats
      ch_variant
}