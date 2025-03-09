#!/bin/bash

#SBATCH -N 1  # Ensure that all cores are on one machine
#SBATCH --cpus-per-task=4
#SBATCH --job-name=breseq_anc_clones
#SBATCH --mail-user=nak177@pitt.edu
#SBATCH --mail-type=ALL
#SBATCH --array=0-6  #7 strains
#SBATCH --output=/home/nak177/wgs/new_ref_gdtools/slurm/%x_%A_%a.out
#SBATCH --error=/home/nak177/wgs/new_ref_gdtools/slurm/%x_%A_%a.err

#purpose rerun breseq using new reference seq on clones

new_ref="/home/nak177/wgs/new_ref_gdtools/gdtools_new_ref/pa14_new_ref_gdtools.gbk"
output_base="/home/nak177/wgs/new_ref_gdtools"

input_dirs_1=(
    "/home/nak177/wgs/pa14/2021-07-02/B1/B1_S201_R1_001.fastq.gz" #B1 full
    "/home/nak177/wgs/pa14/2024-02-17/B1_14_S8_R1_001.fastq.gz" #full/mini
    "/home/nak177/wgs/pa14/2024-02-17/B1_9_S7_R1_001.fastq.gz" #full/mini 5
    "/home/nak177/wgs/pa14/2022-01-19/Pf5_cap_del_1_S184_R1_001.fastq.gz" #mini
    "/home/nak177/wgs/pa14/2023-07-21/raw_reads/3603_1_S12_R1_001.fastq.gz" #delPf5
    "/home/nak177/wgs/pa14/2024-03-25/raw_reads/NK1_S13_R1_001.fastq.gz" #pilA
)
input_dirs_2=(
    "/home/nak177/wgs/pa14/2021-07-02/B1/B1_S201_R2_001.fastq.gz" #B1 full
    "/home/nak177/wgs/pa14/2024-02-17/B1_14_S8_R2_001.fastq.gz" #full/mini
    "/home/nak177/wgs/pa14/2024-02-17/B1_9_S7_R2_001.fastq.gz" #full/mini 5
    "/home/nak177/wgs/pa14/2022-01-19/Pf5_cap_del_1_S184_R2_001.fastq.gz" #mini
    "/home/nak177/wgs/pa14/2023-07-21/raw_reads/3603_1_S12_R2_001.fastq.gz" #delPf5
    "/home/nak177/wgs/pa14/2024-03-25/raw_reads/NK1_S13_R2_001.fastq.gz" #pilA
)

# Define output names
output_names=(
    "B1_PA14_full"
    "new_G1_PA14_full_mini"
    "new_G1_PA14_full_mini_5"
    "Pf5_cap_del_1_PA14_mini"
    "delPf5_PA14_del_Pf5"
    "pilA_PA14_del_pilA"
)

input1="${input_dirs_1[$SLURM_ARRAY_TASK_ID]}"
input2="${input_dirs_2[$SLURM_ARRAY_TASK_ID]}"
output_name="${output_names[$SLURM_ARRAY_TASK_ID]}"
output_dir="$output_base/$output_name"

module purge
module load breseq/breseq-0.39.0

breseq -j 4 -r "$new_ref" -o "$output_dir" "$input1" "$input2"

module purge
