#!/usr/bin/env bash

eval "$(conda shell.bash hook)"
conda activate qiime2-amplicon-2025.7

# =============================================================================
# Rarefaction step
# Aim: rarefy a feature table to compare alpha/beta diversity results
# A good forum to understand what it does :
# https://forum.qiime2.org/t/can-someone-help-in-alpha-rarefaction-plotting-depths/4580/16
# =============================================================================

# =============================================================================
# 16S
# =============================================================================

WORKING_DIRECTORY=/nvme/bio/data_fungi/Araucaria_columnaris_diversity/02_amplicon_pipeline/16s/05_qiime2
DATABASE=/nvme/bio/data_fungi/Araucaria_columnaris_diversity/02_amplicon_pipeline/16s/04_database_files

cd $WORKING_DIRECTORY

qiime diversity alpha-rarefaction \
--i-table core/table.qza \
--i-phylogeny tree/rooted-tree.qza \
  --p-max-depth 18956 \
  --p-min-depth 1 \
  --m-metadata-file $DATABASE/sample-metadata_16s.tsv \
  --o-visualization visual/alpha-rarefaction_16s.qzv

# =============================================================================
# ITS
# =============================================================================

WORKING_DIRECTORY=/nvme/bio/data_fungi/Araucaria_columnaris_diversity/02_amplicon_pipeline/its/05_qiime2
DATABASE=/nvme/bio/data_fungi/Araucaria_columnaris_diversity/02_amplicon_pipeline/its/04_database_files

cd $WORKING_DIRECTORY

qiime diversity alpha-rarefaction \
--i-table core/table.qza \
--i-phylogeny tree/rooted-tree.qza \
  --p-max-depth 56292 \
  --p-min-depth 1 \
  --m-metadata-file $DATABASE/sample-metadata_its.tsv \
  --o-visualization visual/alpha-rarefaction_its.qzv
