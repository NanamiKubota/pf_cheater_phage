
The following files are contained within whole_genome_sequencing:

- breseq_data/
  - **breseq_parser_output.csv**: unfiltered variant calls made by breseq where output was created using gdtools. breseq output files were parsed using breseq_parser_script.py found at https://github.com/NanamiKubota/NanamiKubota.github.io/blob/main/scripts/breseq_parser_gdtools.py
  - **breseq_parser_output_filtered.csv**: filtered variant calls using breseq_output_filter.R script
  - **breseq_miniphage.csv**: filtered miniphage deletion region using breseq_output_filter.R script
- **pa14_new_ref_gdtools.gbk**: new reference genome of PA14 created using breseq's gdtools using lab's wildtype PA14 strain
- **breseq_output_filter.R**: R script to clean/filter breseq output file
- **breseq_new_ref_clones.sh**: bash script to run breseq using the new reference genome (pa14_new_ref_gdtools.gbk) on newly isolated clones (PRJNA1226961)
- **breseq_PRJNA692838.sh**: bash script to run breseq using the new reference genome (pa14_new_ref_gdtools.gbk) on raw reads from PRJNA692838

