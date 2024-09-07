#!/usr/bin/env bash

# trimmomatic version 0.39
# trimmomatic manual : http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/TrimmomaticManual_V0.32.pdf

# pathways in cluster:
DATADIRECTORY_ITS=/home/fungi/Araucaria_columnaris_diversity/01_raw_data/ITS
DATADIRECTORY_16S=/home/fungi/Araucaria_columnaris_diversity/01_raw_data/16S
DATAOUTPUT_ITS=/home/fungi/Araucaria_columnaris_diversity/03_cleaned_data/DATAOUTPUT_ITS
DATAOUTPUT_16S=/home/fungi/Araucaria_columnaris_diversity/03_cleaned_data/DATAOUTPUT_16S

WORKING_DIRECTORY=/home/fungi/Araucaria_columnaris_diversity


# pathways in local:
#DATADIRECTORY_ITS=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/18_Araucaria/Araucaria_columnaris_diversity/01_raw_data/ITS
#DATADIRECTORY_16S=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/18_Araucaria/Araucaria_columnaris_diversity/01_raw_data/16S
#DATAOUTPUT_ITS=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/18_Araucaria/Araucaria_columnaris_diversity/03_cleaned_data/DATAOUTPUT_ITS
#DATAOUTPUT_16S=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/18_Araucaria/Araucaria_columnaris_diversity/03_cleaned_data/DATAOUTPUT_16S

eval "$(conda shell.bash hook)"
conda activate trimmomatic

ADAPTERFILE=/home/fungi/dugong_microbiome/99_softwares/adapters_sequences.fasta


cd $WORKING_DIRECTORY

# Make the directory (mkdir) only if not existe already(-p)
mkdir -p $DATAOUTPUT_16S
mkdir -p $DATAOUTPUT_ITS


# cat $ADAPTERFILE
#>Illumina_TruSeq_LT_R1 AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC
#>Illumina_TruSeq_LT_R2 AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT
#>truseq AGATCGGAAGAGC
#>nextera CTGTCTCTTATACACATC
#>small TGGAATTCTCGGGTGCCAAGG
#>ScriptSeqR1 AGATCGGAAGAGCACACGTCTGAAC
#>ScriptSeqR2 AGATCGGAAGAGCGTCGTGTAGGGA
#>TruSeqRibo AGATCGGAAGAGCACACGTCT

# Arguments :
# ILLUMINACLIP:"$ADAPTERFILE":2:30:10 LEADING:30 TRAILING:30 SLIDINGWINDOW:26:30 MINLEN:150

## For fungi :

cd $DATADIRECTORY_ITS

for R1 in *R1*
do
   R2=${R1//R1_001.fastq.gz/R2_001.fastq.gz}
   R1paired=${R1//.fastq/_paired.fastq.gz}
   R1unpaired=${R1//.fastq/_unpaired.fastq.gz}	
   R2paired=${R2//.fastq/_paired.fastq.gz}
   R2unpaired=${R2//.fastq/_unpaired.fastq.gz}	

   trimmomatic PE -Xmx60G -threads 8 -phred33 $R1 $R2 $DATAOUTPUT_ITS/$R1paired $DATAOUTPUT_ITS/$R1unpaired $DATAOUTPUT_ITS/$R2paired $DATAOUTPUT_ITS/$R2unpaired ILLUMINACLIP:"$ADAPTERFILE":2:30:10 LEADING:30 TRAILING:30 SLIDINGWINDOW:26:30 MINLEN:150

done ;


# For bacteria :

cd $DATADIRECTORY_16S


for R1 in *R1*
do
   R2=${R1//R1_001.fastq.gz/R2_001.fastq.gz}
   R1paired=${R1//.fastq/_paired.fastq.gz}
   R1unpaired=${R1//.fastq/_unpaired.fastq.gz}	
   R2paired=${R2//.fastq/_paired.fastq.gz}
   R2unpaired=${R2//.fastq/_unpaired.fastq.gz}	

   trimmomatic PE -Xmx60G -threads 8 -phred33 $R1 $R2 $DATAOUTPUT_16S/$R1paired $DATAOUTPUT_16S/$R1unpaired $DATAOUTPUT_16S/$R2paired $DATAOUTPUT_16S/$R2unpaired ILLUMINACLIP:"$ADAPTERFILE":2:30:10 LEADING:30 TRAILING:30 SLIDINGWINDOW:26:30 MINLEN:150

done ;
