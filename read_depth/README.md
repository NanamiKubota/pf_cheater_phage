
The read_depth directory contains the following:
- **read_depth.sh**: bash script used to generate read depth calculation and files
- **data/**: contains read depth data of each strain. Read depth was calculated by taking the average reads mapped in a 10bp window.
  - **B1_PA14_full_cov_10.txt**: PA14*full read depth data
  - **delPf5_PA14_del_Pf5_cov_10.txt**: PA14∆Pf5 read depth data
  - **lasR_pf5r_SRR17205267_cov_10.txt**: PA14*full/mini 4 read depth data
  - **morA_pf5r_SRR17205266_cov_10.txt**: PA14*full/mini 3 read depth data
  - **new_G1_PA14_full_mini_cov_10.txt**: PA14*full/mini 1 read depth data
  - **old_G1_PA14_full_mini_2_cov_10.txt**: PA14*full/mini 2 read depth data
  - **PA14WT_cov_10.txt**: PA14 WT read depth data
  - **Pf5_cap_del_1_PA14_mini_cov_10.txt**: PA14*mini read depth data
  - **plank_no_drug_pop5_day12_SRR13453461_cov_10.txt**: evolved population from previous study read depth data
- **Pseudomonas_aeruginosa_UCBPP-PA14_109.csv**: csv file of P. aeruginosa PA14 annotation from the Pseudomonas Genome Database. This file is used to create the gene maps in the manuscript. See the [Rmarkdown document](../pf_cheater_phage_figures.Rmd) for more details.