#!/usr/bin/env bash

# pathways in cluster:
DATADIRECTORY_16S=/scratch_vol1/fungi/Saribus_jeanneneyi/01_raw_data/16S
OUTPUT_16S=/scratch_vol1/fungi/Saribus_jeanneneyi/02_pooled_data/16S

DATADIRECTORY_ITS=/scratch_vol1/fungi/Saribus_jeanneneyi/01_raw_data/ITS
OUTPUT_ITS=/scratch_vol1/fungi/Saribus_jeanneneyi/02_pooled_data/ITS

WORKING_DIRECTORY=/scratch_vol1/fungi/Saribus_jeanneneyi

# pathways in local:
#DATADIRECTORY_16S=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/21_Saribus/Saribus_jeanneneyi/00_raw_data/16S
#OUTPUT_16S=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/21_Saribus/Saribus_jeanneneyi/01_pooled/16S

#DATADIRECTORY_ITS=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/21_Saribus/Saribus_jeanneneyi/00_raw_data/ITS
#OUTPUT_ITS=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/21_Saribus/Saribus_jeanneneyi/01_pooled/ITS

# WARNING : HERE ITS NOT NECESSARY TO POOL SEQ, ONLY CHANGE THE NAME

cd $WORKING_DIRECTORY

# Make the directory (mkdir) only if not existe already(-p)
mkdir -p $OUTPUT_ITS
mkdir -p $OUTPUT_16S

cd $DATADIRECTORY_16S

Ac-A-D2-2B-T11-1_S32_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-A-D2-2B-T11-1_S32_R2.fastq.gz
Ac-A-D1-1A-T11-1_S25_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-A-D1-1A-T11-1_S25_R1.fastq.gz
Ac-A-D1-1A-T11-1_S25_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-A-D1-1A-T11-1_S25_R2.fastq.gz
Ac-A-D1-1B-T11-1_S26_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-A-D1-1B-T11-1_S26_R1.fastq.gz
Ac-A-D1-1B-T11-1_S26_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-A-D1-1B-T11-1_S26_R2.fastq.gz
Ac-A-D1-2A-T11-1_S27_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-A-D1-2A-T11-1_S27_R1.fastq.gz
Ac-A-D1-2A-T11-1_S27_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-A-D1-2A-T11-1_S27_R2.fastq.gz
Ac-A-D1-2B-T11-1_S28_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-A-D1-2B-T11-1_S28_R1.fastq.gz
Ac-A-D1-2B-T11-1_S28_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-A-D1-2B-T11-1_S28_R2.fastq.gz
Ac-A-D2-1A-T11-1_S29_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-A-D2-1A-T11-1_S29_R1.fastq.gz
Ac-A-D2-1A-T11-1_S29_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-A-D2-1A-T11-1_S29_R2.fastq.gz
Ac-A-D2-1B-T11-1_S30_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-A-D2-1B-T11-1_S30_R1.fastq.gz
Ac-A-D2-1B-T11-1_S30_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-A-D2-1B-T11-1_S30_R2.fastq.gz
Ac-A-D2-2A-T11-1_S31_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-A-D2-2A-T11-1_S31_R1.fastq.gz
Ac-A-D2-2A-T11-1_S31_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-A-D2-2A-T11-1_S31_R2.fastq.gz
Ac-A-D2-2B-T11-1_S32_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-A-D2-2B-T11-1_S32_R1.fastq.gz
Ac-A-T-1A-T11-1_S9_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-A-T-1A-T11-1_S9_R1.fastq.gz
Ac-A-T-1A-T11-1_S9_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-A-T-1A-T11-1_S9_R2.fastq.gz
Ac-A-T-1A-T11-1_S13_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-A-T-1A-T11-1_S13_R1.fastq.gz
Ac-A-T-1A-T11-1_S13_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-A-T-1A-T11-1_S13_R2.fastq.gz
Ac-A-T-1B-T11-1_S10_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-A-T-1B-T11-1_S10_R1.fastq.gz
Ac-A-T-1B-T11-1_S10_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-A-T-1B-T11-1_S10_R2.fastq.gz
Ac-A-T-1B-T11-1_S14_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-A-T-1B-T11-1_S14_R1.fastq.gz
Ac-A-T-1B-T11-1_S14_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-A-T-1B-T11-1_S14_R2.fastq.gz
Ac-A-T-2A-T11-1_S11_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-A-T-2A-T11-1_S11_R1.fastq.gz
Ac-A-T-2A-T11-1_S11_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-A-T-2A-T11-1_S11_R2.fastq.gz
Ac-A-T-2A-T11-1_S15_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-A-T-2A-T11-1_S15_R1.fastq.gz
Ac-A-T-2A-T11-1_S15_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-A-T-2A-T11-1_S15_R2.fastq.gz
Ac-A-T-2B-T11-1_S12_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-A-T-2B-T11-1_S12_R1.fastq.gz
Ac-A-T-2B-T11-1_S12_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-A-T-2B-T11-1_S12_R2.fastq.gz
Ac-A-T-2B-T11-1_S16_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-A-T-2B-T11-1_S16_R1.fastq.gz
Ac-A-T-2B-T11-1_S16_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-A-T-2B-T11-1_S16_R2.fastq.gz
Ac-B-D1-1A-T11-1_S57_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-B-D1-1A-T11-1_S57_R1.fastq.gz
Ac-B-D1-1A-T11-1_S57_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-B-D1-1A-T11-1_S57_R2.fastq.gz
Ac-B-D1-1B-T11-1_S58_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-B-D1-1B-T11-1_S58_R1.fastq.gz
Ac-B-D1-1B-T11-1_S58_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-B-D1-1B-T11-1_S58_R2.fastq.gz
Ac-B-D1-2A-T11-1_S59_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-B-D1-2A-T11-1_S59_R1.fastq.gz
Ac-B-D1-2A-T11-1_S59_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-B-D1-2A-T11-1_S59_R2.fastq.gz
Ac-B-D1-2B-T11-1_S60_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-B-D1-2B-T11-1_S60_R1.fastq.gz
Ac-B-D1-2B-T11-1_S60_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-B-D1-2B-T11-1_S60_R2.fastq.gz
Ac-B-D2-1A-T11-1_S61_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-B-D2-1A-T11-1_S61_R1.fastq.gz
Ac-B-D2-1A-T11-1_S61_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-B-D2-1A-T11-1_S61_R2.fastq.gz
Ac-B-D2-1B-T11-1_S62_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-B-D2-1B-T11-1_S62_R1.fastq.gz
Ac-B-D2-1B-T11-1_S62_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-B-D2-1B-T11-1_S62_R2.fastq.gz
Ac-B-D2-2A-T11-1_S63_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-B-D2-2A-T11-1_S63_R1.fastq.gz
Ac-B-D2-2A-T11-1_S63_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-B-D2-2A-T11-1_S63_R2.fastq.gz
Ac-B-D2-2B-T11-1_S64_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-B-D2-2B-T11-1_S64_R1.fastq.gz
Ac-B-D2-2B-T11-1_S64_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-B-D2-2B-T11-1_S64_R2.fastq.gz
Ac-B-T-1A-T11-1_S41_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-B-T-1A-T11-1_S41_R1.fastq.gz
Ac-B-T-1A-T11-1_S41_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-B-T-1A-T11-1_S41_R2.fastq.gz
Ac-B-T-1A-T11-1_S45_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-B-T-1A-T11-1_S45_R1.fastq.gz
Ac-B-T-1A-T11-1_S45_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-B-T-1A-T11-1_S45_R2.fastq.gz
Ac-B-T-1B-T11-1_S42_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-B-T-1B-T11-1_S42_R1.fastq.gz
Ac-B-T-1B-T11-1_S42_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-B-T-1B-T11-1_S42_R2.fastq.gz
Ac-B-T-1B-T11-1_S46_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-B-T-1B-T11-1_S46_R1.fastq.gz
Ac-B-T-1B-T11-1_S46_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-B-T-1B-T11-1_S46_R2.fastq.gz
Ac-B-T-2A-T11-1_S43_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-B-T-2A-T11-1_S43_R1.fastq.gz
Ac-B-T-2A-T11-1_S43_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-B-T-2A-T11-1_S43_R2.fastq.gz
Ac-B-T-2A-T11-1_S47_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-B-T-2A-T11-1_S47_R1.fastq.gz
Ac-B-T-2A-T11-1_S47_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-B-T-2A-T11-1_S47_R2.fastq.gz
Ac-B-T-2B-T11-1_S44_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-B-T-2B-T11-1_S44_R1.fastq.gz
Ac-B-T-2B-T11-1_S44_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-B-T-2B-T11-1_S44_R2.fastq.gz
Ac-B-T-2B-T11-1_S48_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-B-T-2B-T11-1_S48_R1.fastq.gz
Ac-B-T-2B-T11-1_S48_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-B-T-2B-T11-1_S48_R2.fastq.gz
Ac-C-D1-1A-T11-1_S89_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-C-D1-1A-T11-1_S89_R1.fastq.gz
Ac-C-D1-1A-T11-1_S89_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-C-D1-1A-T11-1_S89_R2.fastq.gz
Ac-C-D1-1B-T11-1_S90_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-C-D1-1B-T11-1_S90_R1.fastq.gz
Ac-C-D1-1B-T11-1_S90_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-C-D1-1B-T11-1_S90_R2.fastq.gz
Ac-C-D1-2A-T11-1_S91_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-C-D1-2A-T11-1_S91_R1.fastq.gz
Ac-C-D1-2A-T11-1_S91_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-C-D1-2A-T11-1_S91_R2.fastq.gz
Ac-C-D1-2B-T11-1_S92_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-C-D1-2B-T11-1_S92_R1.fastq.gz
Ac-C-D1-2B-T11-1_S92_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-C-D1-2B-T11-1_S92_R2.fastq.gz
Ac-C-D2-1A-T11-1_S93_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-C-D2-1A-T11-1_S93_R1.fastq.gz
Ac-C-D2-1A-T11-1_S93_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-C-D2-1A-T11-1_S93_R2.fastq.gz
Ac-C-D2-1B-T11-1_S94_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-C-D2-1B-T11-1_S94_R1.fastq.gz
Ac-C-D2-1B-T11-1_S94_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-C-D2-1B-T11-1_S94_R2.fastq.gz
Ac-C-D2-2A-T11-1_S95_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-C-D2-2A-T11-1_S95_R1.fastq.gz
Ac-C-D2-2A-T11-1_S95_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-C-D2-2A-T11-1_S95_R2.fastq.gz
Ac-C-D2-2B-T11-1_S104_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-C-D2-2B-T11-1_S104_R1.fastq.gz
Ac-C-D2-2B-T11-1_S104_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-C-D2-2B-T11-1_S104_R2.fastq.gz
Ac-C-T-1A-T11-1_S73_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-C-T-1A-T11-1_S73_R1.fastq.gz
Ac-C-T-1A-T11-1_S73_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-C-T-1A-T11-1_S73_R2.fastq.gz
Ac-C-T-1A-T11-1_S77_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-C-T-1A-T11-1_S77_R1.fastq.gz
Ac-C-T-1A-T11-1_S77_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-C-T-1A-T11-1_S77_R2.fastq.gz
Ac-C-T-1B-T11-1_S74_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-C-T-1B-T11-1_S74_R1.fastq.gz
Ac-C-T-1B-T11-1_S74_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-C-T-1B-T11-1_S74_R2.fastq.gz
Ac-C-T-1B-T11-1_S78_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-C-T-1B-T11-1_S78_R1.fastq.gz
Ac-C-T-1B-T11-1_S78_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-C-T-1B-T11-1_S78_R2.fastq.gz
Ac-C-T-2A-T11-1_S75_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-C-T-2A-T11-1_S75_R1.fastq.gz
Ac-C-T-2A-T11-1_S75_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-C-T-2A-T11-1_S75_R2.fastq.gz
Ac-C-T-2A-T11-1_S79_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-C-T-2A-T11-1_S79_R1.fastq.gz
Ac-C-T-2A-T11-1_S79_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-C-T-2A-T11-1_S79_R2.fastq.gz
Ac-C-T-2B-T11-1_S76_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-C-T-2B-T11-1_S76_R1.fastq.gz
Ac-C-T-2B-T11-1_S76_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-C-T-2B-T11-1_S76_R2.fastq.gz
Ac-C-T-2B-T11-1_S80_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-C-T-2B-T11-1_S80_R1.fastq.gz
Ac-C-T-2B-T11-1_S80_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-C-T-2B-T11-1_S80_R2.fastq.gz
Ac-NEG-T11-1_S105_L001_R1_001.fastq.gz > $OUTPUT_16S/Ac-NEG-T11-1_S105_R1.fastq.gz
Ac-NEG-T11-1_S105_L001_R2_001.fastq.gz > $OUTPUT_16S/Ac-NEG-T11-1_S105_R2.fastq.gz

cd $DATADIRECTORY_ITS

Ac-A-D2-2B-T11-1_S32_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-A-D2-2B-T11-1_S32_R2.fastq.gz
Ac-A-D1-1A-T11-1_S25_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-A-D1-1A-T11-1_S25_R1.fastq.gz
Ac-A-D1-1A-T11-1_S25_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-A-D1-1A-T11-1_S25_R2.fastq.gz
Ac-A-D1-1B-T11-1_S26_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-A-D1-1B-T11-1_S26_R1.fastq.gz
Ac-A-D1-1B-T11-1_S26_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-A-D1-1B-T11-1_S26_R2.fastq.gz
Ac-A-D1-2A-T11-1_S27_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-A-D1-2A-T11-1_S27_R1.fastq.gz
Ac-A-D1-2A-T11-1_S27_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-A-D1-2A-T11-1_S27_R2.fastq.gz
Ac-A-D1-2B-T11-1_S28_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-A-D1-2B-T11-1_S28_R1.fastq.gz
Ac-A-D1-2B-T11-1_S28_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-A-D1-2B-T11-1_S28_R2.fastq.gz
Ac-A-D2-1A-T11-1_S29_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-A-D2-1A-T11-1_S29_R1.fastq.gz
Ac-A-D2-1A-T11-1_S29_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-A-D2-1A-T11-1_S29_R2.fastq.gz
Ac-A-D2-1B-T11-1_S30_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-A-D2-1B-T11-1_S30_R1.fastq.gz
Ac-A-D2-1B-T11-1_S30_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-A-D2-1B-T11-1_S30_R2.fastq.gz
Ac-A-D2-2A-T11-1_S31_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-A-D2-2A-T11-1_S31_R1.fastq.gz
Ac-A-D2-2A-T11-1_S31_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-A-D2-2A-T11-1_S31_R2.fastq.gz
Ac-A-D2-2B-T11-1_S32_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-A-D2-2B-T11-1_S32_R1.fastq.gz
Ac-A-T-1A-T11-1_S9_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-A-T-1A-T11-1_S9_R1.fastq.gz
Ac-A-T-1A-T11-1_S9_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-A-T-1A-T11-1_S9_R2.fastq.gz
Ac-A-T-1A-T11-1_S13_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-A-T-1A-T11-1_S13_R1.fastq.gz
Ac-A-T-1A-T11-1_S13_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-A-T-1A-T11-1_S13_R2.fastq.gz
Ac-A-T-1B-T11-1_S10_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-A-T-1B-T11-1_S10_R1.fastq.gz
Ac-A-T-1B-T11-1_S10_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-A-T-1B-T11-1_S10_R2.fastq.gz
Ac-A-T-1B-T11-1_S14_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-A-T-1B-T11-1_S14_R1.fastq.gz
Ac-A-T-1B-T11-1_S14_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-A-T-1B-T11-1_S14_R2.fastq.gz
Ac-A-T-2A-T11-1_S11_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-A-T-2A-T11-1_S11_R1.fastq.gz
Ac-A-T-2A-T11-1_S11_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-A-T-2A-T11-1_S11_R2.fastq.gz
Ac-A-T-2A-T11-1_S15_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-A-T-2A-T11-1_S15_R1.fastq.gz
Ac-A-T-2A-T11-1_S15_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-A-T-2A-T11-1_S15_R2.fastq.gz
Ac-A-T-2B-T11-1_S12_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-A-T-2B-T11-1_S12_R1.fastq.gz
Ac-A-T-2B-T11-1_S12_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-A-T-2B-T11-1_S12_R2.fastq.gz
Ac-A-T-2B-T11-1_S16_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-A-T-2B-T11-1_S16_R1.fastq.gz
Ac-A-T-2B-T11-1_S16_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-A-T-2B-T11-1_S16_R2.fastq.gz
Ac-B-D1-1A-T11-1_S57_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-B-D1-1A-T11-1_S57_R1.fastq.gz
Ac-B-D1-1A-T11-1_S57_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-B-D1-1A-T11-1_S57_R2.fastq.gz
Ac-B-D1-1B-T11-1_S58_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-B-D1-1B-T11-1_S58_R1.fastq.gz
Ac-B-D1-1B-T11-1_S58_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-B-D1-1B-T11-1_S58_R2.fastq.gz
Ac-B-D1-2A-T11-1_S59_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-B-D1-2A-T11-1_S59_R1.fastq.gz
Ac-B-D1-2A-T11-1_S59_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-B-D1-2A-T11-1_S59_R2.fastq.gz
Ac-B-D1-2B-T11-1_S60_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-B-D1-2B-T11-1_S60_R1.fastq.gz
Ac-B-D1-2B-T11-1_S60_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-B-D1-2B-T11-1_S60_R2.fastq.gz
Ac-B-D2-1A-T11-1_S61_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-B-D2-1A-T11-1_S61_R1.fastq.gz
Ac-B-D2-1A-T11-1_S61_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-B-D2-1A-T11-1_S61_R2.fastq.gz
Ac-B-D2-1B-T11-1_S62_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-B-D2-1B-T11-1_S62_R1.fastq.gz
Ac-B-D2-1B-T11-1_S62_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-B-D2-1B-T11-1_S62_R2.fastq.gz
Ac-B-D2-2A-T11-1_S63_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-B-D2-2A-T11-1_S63_R1.fastq.gz
Ac-B-D2-2A-T11-1_S63_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-B-D2-2A-T11-1_S63_R2.fastq.gz
Ac-B-D2-2B-T11-1_S64_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-B-D2-2B-T11-1_S64_R1.fastq.gz
Ac-B-D2-2B-T11-1_S64_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-B-D2-2B-T11-1_S64_R2.fastq.gz
Ac-B-T-1A-T11-1_S41_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-B-T-1A-T11-1_S41_R1.fastq.gz
Ac-B-T-1A-T11-1_S41_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-B-T-1A-T11-1_S41_R2.fastq.gz
Ac-B-T-1A-T11-1_S45_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-B-T-1A-T11-1_S45_R1.fastq.gz
Ac-B-T-1A-T11-1_S45_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-B-T-1A-T11-1_S45_R2.fastq.gz
Ac-B-T-1B-T11-1_S42_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-B-T-1B-T11-1_S42_R1.fastq.gz
Ac-B-T-1B-T11-1_S42_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-B-T-1B-T11-1_S42_R2.fastq.gz
Ac-B-T-1B-T11-1_S46_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-B-T-1B-T11-1_S46_R1.fastq.gz
Ac-B-T-1B-T11-1_S46_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-B-T-1B-T11-1_S46_R2.fastq.gz
Ac-B-T-2A-T11-1_S43_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-B-T-2A-T11-1_S43_R1.fastq.gz
Ac-B-T-2A-T11-1_S43_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-B-T-2A-T11-1_S43_R2.fastq.gz
Ac-B-T-2A-T11-1_S47_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-B-T-2A-T11-1_S47_R1.fastq.gz
Ac-B-T-2A-T11-1_S47_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-B-T-2A-T11-1_S47_R2.fastq.gz
Ac-B-T-2B-T11-1_S44_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-B-T-2B-T11-1_S44_R1.fastq.gz
Ac-B-T-2B-T11-1_S44_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-B-T-2B-T11-1_S44_R2.fastq.gz
Ac-B-T-2B-T11-1_S48_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-B-T-2B-T11-1_S48_R1.fastq.gz
Ac-B-T-2B-T11-1_S48_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-B-T-2B-T11-1_S48_R2.fastq.gz
Ac-C-D1-1A-T11-1_S89_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-C-D1-1A-T11-1_S89_R1.fastq.gz
Ac-C-D1-1A-T11-1_S89_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-C-D1-1A-T11-1_S89_R2.fastq.gz
Ac-C-D1-1B-T11-1_S90_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-C-D1-1B-T11-1_S90_R1.fastq.gz
Ac-C-D1-1B-T11-1_S90_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-C-D1-1B-T11-1_S90_R2.fastq.gz
Ac-C-D1-2A-T11-1_S91_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-C-D1-2A-T11-1_S91_R1.fastq.gz
Ac-C-D1-2A-T11-1_S91_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-C-D1-2A-T11-1_S91_R2.fastq.gz
Ac-C-D1-2B-T11-1_S92_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-C-D1-2B-T11-1_S92_R1.fastq.gz
Ac-C-D1-2B-T11-1_S92_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-C-D1-2B-T11-1_S92_R2.fastq.gz
Ac-C-D2-1A-T11-1_S93_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-C-D2-1A-T11-1_S93_R1.fastq.gz
Ac-C-D2-1A-T11-1_S93_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-C-D2-1A-T11-1_S93_R2.fastq.gz
Ac-C-D2-1B-T11-1_S94_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-C-D2-1B-T11-1_S94_R1.fastq.gz
Ac-C-D2-1B-T11-1_S94_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-C-D2-1B-T11-1_S94_R2.fastq.gz
Ac-C-D2-2A-T11-1_S95_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-C-D2-2A-T11-1_S95_R1.fastq.gz
Ac-C-D2-2A-T11-1_S95_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-C-D2-2A-T11-1_S95_R2.fastq.gz
Ac-C-D2-2B-T11-1_S104_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-C-D2-2B-T11-1_S104_R1.fastq.gz
Ac-C-D2-2B-T11-1_S104_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-C-D2-2B-T11-1_S104_R2.fastq.gz
Ac-C-T-1A-T11-1_S73_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-C-T-1A-T11-1_S73_R1.fastq.gz
Ac-C-T-1A-T11-1_S73_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-C-T-1A-T11-1_S73_R2.fastq.gz
Ac-C-T-1A-T11-1_S77_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-C-T-1A-T11-1_S77_R1.fastq.gz
Ac-C-T-1A-T11-1_S77_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-C-T-1A-T11-1_S77_R2.fastq.gz
Ac-C-T-1B-T11-1_S74_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-C-T-1B-T11-1_S74_R1.fastq.gz
Ac-C-T-1B-T11-1_S74_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-C-T-1B-T11-1_S74_R2.fastq.gz
Ac-C-T-1B-T11-1_S78_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-C-T-1B-T11-1_S78_R1.fastq.gz
Ac-C-T-1B-T11-1_S78_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-C-T-1B-T11-1_S78_R2.fastq.gz
Ac-C-T-2A-T11-1_S75_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-C-T-2A-T11-1_S75_R1.fastq.gz
Ac-C-T-2A-T11-1_S75_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-C-T-2A-T11-1_S75_R2.fastq.gz
Ac-C-T-2A-T11-1_S79_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-C-T-2A-T11-1_S79_R1.fastq.gz
Ac-C-T-2A-T11-1_S79_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-C-T-2A-T11-1_S79_R2.fastq.gz
Ac-C-T-2B-T11-1_S76_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-C-T-2B-T11-1_S76_R1.fastq.gz
Ac-C-T-2B-T11-1_S76_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-C-T-2B-T11-1_S76_R2.fastq.gz
Ac-C-T-2B-T11-1_S80_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-C-T-2B-T11-1_S80_R1.fastq.gz
Ac-C-T-2B-T11-1_S80_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-C-T-2B-T11-1_S80_R2.fastq.gz
Ac-NEG-T11-1_S105_L001_R1_001.fastq.gz > $OUTPUT_ITS/Ac-NEG-T11-1_S105_R1.fastq.gz
Ac-NEG-T11-1_S105_L001_R2_001.fastq.gz > $OUTPUT_ITS/Ac-NEG-T11-1_S105_R2.fastq.gz


