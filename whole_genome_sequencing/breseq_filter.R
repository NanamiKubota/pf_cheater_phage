
#R script to filter out variant calls made by breseq

#set working directory
setwd("/Users/kubotan/Documents/github/pf_cheater_phage")

#load libraries
library(tidyverse)

#read breseq_parser_output.csv
breseq_output <- read.csv("./whole_genome_sequencing/breseq_data/breseq_parser_output.csv") %>%
  dplyr::filter(type != "UN") %>% #filter out unknown base evidence
  #split read coverage column (number of reads supporting forward / reverse strand):
  separate(new_cov, into = c("new_cov_left", "new_cov_right"), sep = "/", fill = "right") %>%
  separate(ref_cov, into = c("ref_cov_left", "ref_cov_right"), sep = "/", fill = "right") %>%
  separate(total_cov, into = c("total_cov_left", "total_cov_right"), sep = "/", fill = "right") %>%
  #calculate total read coverage that supports original/reference call and variant call
  mutate(
    across(c(new_cov_left, new_cov_right, ref_cov_left, ref_cov_right, total_cov_left, total_cov_right), as.numeric), #convert to numeric class
    total_new_cov = new_cov_left + new_cov_right, #total reads supporting new variant call
    total_ref_cov = ref_cov_left + ref_cov_right, #total reads supporting original call
    total_coverage = total_cov_left + total_cov_right, #total coverage
    total_read_count = new_read_count + ref_read_count # total read count (for intergenic region)
    ) %>%
  #filter to keep variant calls that are supported by enough reads
  filter(
    (new_cov_left >= 3 & new_cov_right >= 3) | is.na(total_coverage), #at least 3 reads supporting variant call on both forward and reverse strand
    (coverage_minus >= 3 & coverage_plus >= 3) | (is.na(coverage_minus) | is.na(coverage_plus)), #at least 3 reads supporting variant call for new junction calls
    total_coverage >= 10 | is.na(total_coverage), #at least a coverage of 10 reads
    ) %>%
  select(where(~ any(!is.na(.)))) #remove columns with only NAs

#column names with identifying info on variant calls
columns_to_select <- c("gene_name", "gene_product", "side_1_gene_name", "side_1_gene_product", "side_2_gene_name", "side_2_gene_product", "type", "insert_position", "position", "position_start", "position_end", "side_1_position", "side_2_position", "side_1_strand", "side_2_strand", "new_junction_read_count", "unique_read_sequence", "start", "end")

#subset PA14 WT calls
wt_output <- breseq_output %>%
  dplyr::filter(breseq == "PA14_WT") 

breseq_output_rm_anc <- breseq_output %>%
  #remove calls that are found in PA14 WT
  anti_join(wt_output, by = columns_to_select) %>% 
  #remove calls that are often from sequencing errors (like regions of repeat regions and missing coverage)
  filter(
    #remove calls due to missing coverage in specific genes (often due to repeat region and bad coverage)
    !(type == "MC" & gene_name %in% c("vgrG4b", "vgrG14", "[phzG2]–[phzD2]", "[hcp2]", "[PA14_55631]")),
    #remove calls in intergenic rpsF/PA14_65190 and PA14_61200 which has a lot of Gs and prone to sequencing error
    !(type %in% c("RA", "SNP", "JC", "DEL") & gene_name %in% c("rpsF/PA14_65190")),
    !(type == "JC" & (side_1_gene_name == "rpsF/PA14_65190" | side_2_gene_name == "rpsF/PA14_65190")),
    !(type == "JC" & (side_1_gene_name == "PA14_61200" | side_2_gene_name == "PA14_61200")),
    !(type == "JC" & (side_1_gene_name == "PA14_34820" | side_2_gene_name == "PA14_34820")),
    #remove calls that are SNP with less than 10 reads count
    (total_read_count >= 10) | type != "SNP",
    #remove calls that are JC with less than 10 reads count (unless it's the pf5r mutation since this becomes low read coverage relative to the bacterial genome coverage in PA14*mini)
    (new_junction_read_count >= 10 | side_1_gene_name == "pf5r") | type != "JC",
    #remove calls that have ignore flag (variant call made due to circularization of bacterial chromosome) or consensus_reject flag (variant calls where there are multiple calls at the same position; often due to low quality sequencing) or deleted flag
    is.na(ignore) & is.na(consensus_reject) & is.na(deleted),
    #remove calls due to reference genome having "N" base rather than A, T, G, or C
    (ref_base != "N" | is.na(ref_base)) & (ref_seq != "N" | is.na(ref_seq))
  ) %>%
  #additional filters
  filter(
    #remove synonymous mutations
    snp_type != "synonymous" | is.na(snp_type), 
    #remove variant calls that are present in all strains (not in sequenced PA14 WT but in subsequent lineages that arose from PA14 WT, likely due mutation accumulation during strain construction)
    !(gene_name == "PA14_22090/PA14_22100" & position == 1924453) | is.na(gene_name),
    #remove missing coverage (MC) calls -> if they're true deletions, then there is a DEL and JC variant calls that supports this. Other MC calls without supporting DEL/JC calls are most likely due to low coverage
    type != "MC",
    #remove IS element circularization
    !(type == "JC" & side_1_gene_name %in% c("PA14_35700/PA14_35710", "PA14_35710", "PA14_35720", "PA14_35720/PA14_35730", "PA14_35730", "PA14_35730/PA14_35740") | side_2_gene_name %in% c("PA14_35710", "PA14_35700/PA14_35710", "PA14_35720", "PA14_35720/PA14_35730", "PA14_35730")) | type != "JC"
    ) 

write.csv(breseq_output_rm_anc, "./whole_genome_sequencing/breseq_data/breseq_parser_output_filter.csv", row.names = F)


#### miniphage deletion regions
#subset miniphage junction calls for supplemental figure

pf_start_position <- 4344257 #start of Pf5 prophage region
pf_end_position <- 4356442 #end of Pf5 prophage region

mini_bound <- breseq_output_rm_anc %>%
  filter(
    #subset junction calls
    type == "JC",
    
    #of those junction calls, subset juction calls that fall within Pf5 prophage region
    (side_1_position >= pf_start_position & side_1_position <= pf_end_position) &
      (side_2_position >= pf_start_position & side_2_position <= pf_end_position),
    
    #subset junction calls that are due to deletion
    side_1_strand == -1 & side_2_strand == 1,
    
    #remove calls that are due to Pf circularization or loss from bacterial chromosome
    !(side_1_position == 4345107 & side_2_position == 4355773),
    !(side_1_position == 4345098 & side_2_position == 4355762),
    
    #remove calls for pf5r mutation
    !(side_1_gene_name %in% c("pf5r", "xisF5/pf5r") & side_2_gene_name %in% c("pf5r", "xisF5/pf5r"))
  )%>%
  select(breseq, side_1_locus_tag, side_1_gene_name, side_1_gene_product, side_1_position, side_1_strand, side_2_locus_tag, side_2_gene_name, side_2_gene_product, side_2_position, side_2_strand, frequency, coverage_minus, coverage_plus, new_junction_read_count) %>% #keep only columns of interest%>%
# select(where(~ any(!is.na(.)))) 
  mutate(
    #add strain label
    strain = case_when(
      breseq == "Pf5_cap_del_1_PA14_mini" ~ "PA14*mini",
      breseq == "new_G1_PA14_full_mini" ~ "PA14*full/mini 1",
      breseq == "old_G1_PA14_full_mini_2" ~ "PA14*full/mini 2",
      breseq == "morA_pf5r_SRR17205266" ~ "PA14*full/mini 3",
      breseq == "lasR_pf5r_SRR17205267" ~ "PA14*full/mini 4"
    ),
    color = case_when(
      breseq == "Pf5_cap_del_1_PA14_mini" ~ "orange",
      breseq == "new_G1_PA14_full_mini" ~ "#E31A1C",
      breseq == "old_G1_PA14_full_mini_2" ~ "#8DA0CB",
      breseq == "morA_pf5r_SRR17205266" ~ "#E78AC3",
      breseq == "lasR_pf5r_SRR17205267" ~ "#A6D854"
    )
  )

write.csv(mini_bound, "./whole_genome_sequencing/breseq_data/breseq_miniphage.csv", row.names = F)
