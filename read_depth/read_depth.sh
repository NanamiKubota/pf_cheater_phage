#!/bin/bash

#SBATCH -N 1  # Ensure that all cores are on one machine
#SBATCH --nodelist=node02  # Name of node
#SBATCH --job-name=read_depth
#SBATCH --mail-user=nak177@pitt.edu
#SBATCH --mail-type=ALL

output_base="/home/nak177/wgs/new_ref_gdtools/read_depth"

#PRJNA1226961
input_base="/home/nak177/wgs/new_ref_gdtools"
input_names=(
    "B1_PA14_full" #B1 PA14*full
    "new_G1_PA14_full_mini" #new G1 PA14*full/mini
    "old_G1_PA14_full_mini_2" #PA14*full/mini 2
    "Pf5_cap_del_1_PA14_mini" #PA14*mini
    "delPf5_PA14_del_Pf5" #PA14delPf5
)

#PRJNA692838
input_base2="/home/nak177/wgs/shelly/PRJNA692838"
input_names2=(
    "morA_pf5r_SRR17205266" #PA14*full/mini 3
    "lasR_pf5r_SRR17205267" #PA14*full/mini 4
    "plank_no_drug_pop5_day12_SRR13453461" #pf5r exp evo pop
)

module purge
module load samtools/samtools-1.21 bedtools/bedtools-2.26.0

#PRJNA1226961
for sample in "${input_names[@]}"; do
    
    #filepath to breseq data directory
    input_data_base="$input_base/$sample/data"

    #create fasta.fai index file
    samtools faidx "$input_data_base/reference.fasta"

    #create a new file 'reference.txt' which contains information on your contigs and length
    awk -v OFS='\t' {'print $1,$2'} "$input_data_base/reference.fasta.fai" > "$input_data_base/reference.txt"

    #create a 10bp window across whole genome
    bedtools makewindows -g "$input_data_base/reference.txt" -w 10 > "$input_data_base/reference.windows.bed"

    #calculates average read depth across a 10bp window
    samtools depth -a "$input_data_base/reference.bam" | awk '{sum+=$3} (NR%10)==0{print sum/10; sum=0;}' > "$input_data_base/$sample"_cov_10a.txt

    #combine contig name, start and end positions across 10bp, and average read depth
    paste "$input_data_base/reference.windows.bed" "$input_data_base/$sample"_cov_10a.txt > "$output_base/$sample"_cov_10.txt

done

#PRJNA692838
for sample in "${input_names2[@]}"; do
    
    #filepath to breseq data directory
    input_data_base="$input_base2/$sample/data"

    #create fasta.fai index file
    samtools faidx "$input_data_base/reference.fasta"

    #create a new file 'reference.txt' which contains information on your contigs and length
    awk -v OFS='\t' {'print $1,$2'} "$input_data_base/reference.fasta.fai" > "$input_data_base/reference.txt"

    #create a 10bp window across whole genome
    bedtools makewindows -g "$input_data_base/reference.txt" -w 10 > "$input_data_base/reference.windows.bed"

    #calculates average read depth across a 10bp window
    samtools depth -a "$input_data_base/reference.bam" | awk '{sum+=$3} (NR%10)==0{print sum/10; sum=0;}' > "$input_data_base/$sample"_cov_10a.txt

    #combine contig name, start and end positions across 10bp, and average read depth
    paste "$input_data_base/reference.windows.bed" "$input_data_base/$sample"_cov_10a.txt > "$output_base/$sample"_cov_10.txt

done

module purge