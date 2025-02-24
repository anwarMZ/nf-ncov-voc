#!/usr/bin/env nextflow

// enable dsl2
nextflow.enable.dsl = 2

// include workflows
include { COVIDMVP           } from './workflows/covidmvp'
include { POXMVP             } from './workflows/poxmvp'
include { WASTEWATER         } from './workflows/virusmvp_wastewater'

// include subworkflows
include { CONFIGURE_VIRUSMVP } from './subworkflows/local/virusmvp_config'

// include modules
include { printHelp          } from './modules/local/help'
include { cidgohHeader       } from './modules/local/header'
include { workflowHeader     } from './modules/local/wf_header'

// main workflow
workflow {
      if (params.help) {
            log.info(cidgohHeader())
            log.info(workflowHeader())
            printHelp()
            exit(0)
      }

      if (params.profile) {
            println("Profile should have a single dash: -profile")
            System.exit(1)
      }

      if (!params.prefix) {
            println("Please supply a prefix for your output files with --prefix")
            println("Use --help to print help")
            System.exit(1)
      }
      else {
            if (params.prefix =~ /\//) {
                  println("The --prefix that you supplied contains a \"/\", please replace it with another character")
                  System.exit(1)
            }
      }
      log.info(cidgohHeader())
      log.info(workflowHeader())

      if (!params.skip_permissions) {
            try {
                  def scriptFiles = file("${baseDir}/bin/*")
                  scriptFiles.each { file ->
                        if (file.isFile()) {
                              file.setPermissions('rwxr-xr-x')
                        }
                  }
            }
            catch (Exception e) {
                  log.warn("Unable to set permissions for script files: ${e.message}")
            }
      }
      CONFIGURE_VIRUSMVP()
      json_file = file(params.genecoord, checkIfExists: true)
      ch_json = Channel.of(tuple([id: params.virus_accession_id], json_file))
      ch_snpeff_db = CONFIGURE_VIRUSMVP.out.ch_snpeff_db
      ch_snpeff_config = CONFIGURE_VIRUSMVP.out.ch_snpeff_config

      if (params.wastewater) {
            log.info("Running WASTEWATER workflow")
            WASTEWATER(ch_json, ch_snpeff_db, ch_snpeff_config)
      }
      else if (params.virus_accession_id == "NC_045512.2") {
            log.info("Executing COVIDMVP workflow")
            COVIDMVP(ch_json, ch_snpeff_db, ch_snpeff_config)
      }
      else if (params.virus_accession_id == "NC_063383.1") {
            log.info("Executing POXMVP workflow")
            POXMVP(ch_json, ch_snpeff_db, ch_snpeff_config)
      }
      else {
            error("Unsupported virus accession ID: ${params.virus_accession_id}")
      }
}
