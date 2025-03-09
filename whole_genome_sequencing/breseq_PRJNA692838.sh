#!/bin/bash

#SBATCH -N 1  # Ensure that all cores are on one machine
#SBATCH --nodelist=node02  # Name of node
#SBATCH --job-name=breseq_PRJNA692838
#SBATCH --mail-user=nak177@pitt.edu
#SBATCH --mail-type=ALL

module purge
module load breseq/breseq-0.39.0

ref_genome="/home/nak177/wgs/new_ref_gdtools/gdtools_new_ref/pa14_new_ref_gdtools.gbk"

breseq -r "$ref_genome" -o /home/nak177/wgs/shelly/PRJNA692838/morA_pf5r_SRR17205266 /home/nak177/wgs/shelly/PRJNA692838/SRR17205266.fastq.gz

breseq -r "$ref_genome" -o /home/nak177/wgs/shelly/PRJNA692838/lasR_pf5r_SRR17205267 /home/nak177/wgs/shelly/PRJNA692838/SRR17205267.fastq.gz

breseq -p -r "$ref_genome" -o /home/nak177/wgs/shelly/PRJNA692838/plank_no_drug_pop5_day12_SRR13453461 /home/nak177/wgs/shelly/PRJNA692838/SRR13453461.fastq.gz

module purge