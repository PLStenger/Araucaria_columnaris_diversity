#!/usr/bin/env bash
# =============================================================================
# Taxonomie QIIME 2 amplicon 2025.7 : 16S V4 (SILVA) et ITS2 (UNITE)
# Projet : Araucaria_columnaris_diversity
#
# Ce script est conçu pour être exécuté APRES :
# 001_pipeline_QIIME2_PE_Araucaria_columnaris_diversity.sh
#
# Entrées attendues :
#   02_amplicon_pipeline/16s/05_qiime2/core/table.qza
#   02_amplicon_pipeline/16s/05_qiime2/core/rep-seqs.qza
#   02_amplicon_pipeline/16s/04_database_files/sample-metadata_16s.tsv
#   02_amplicon_pipeline/its/05_qiime2/core/table.qza
#   02_amplicon_pipeline/its/05_qiime2/core/rep-seqs.qza
#   02_amplicon_pipeline/its/04_database_files/sample-metadata_its.tsv
#
# Produits, pour chaque marqueur :
#   * références téléchargées / importées ;
#   * références extraites in silico pour le locus amplifié ;
#   * classifieur naïf de Bayes entraîné localement ;
#   * taxonomie des ASV, qzv de consultation et taxa barplot ;
#   * exports TSV/FASTA des résultats.
#
# Important :
# - 16S : amorces 515F/806R, donc V4 (et non V4-V5 du script historique).
# - ITS : ITS7/ITS4 est une PCR très longue couvrant ITS2 + 5.8S + ITS1 selon
#   les taxons. Il est donc risqué d'imposer --p-max-length ; aucune longueur
#   maximale n'est appliquée lors de l'extraction de référence.
# - Les deux amorces sont indiquées dans leur orientation 5' -> 3', sans RC.
# =============================================================================

set -Eeuo pipefail
shopt -s nullglob
IFS=$'\n\t'
trap 'rc=$?; echo "[ERREUR] Code ${rc}, ligne ${LINENO}: ${BASH_COMMAND}" >&2; exit "${rc}"' ERR

# ------------------------------- CONFIGURATION ------------------------------
PROJECT_NAME="Araucaria_columnaris_diversity"
PROJECT_DIR="/nvme/bio/data_fungi/${PROJECT_NAME}"
RESULTS_DIR="${PROJECT_DIR}/02_amplicon_pipeline"
TMPDIR_BASE="${PROJECT_DIR}/tmp"
LOG_DIR="${RESULTS_DIR}/logs"

QIIME2_ENV="qiime2-amplicon-2025.7"
THREADS=8

# Mettre false pour réutiliser les références/classifieurs déjà construits.
REBUILD_16S_CLASSIFIER=true
REBUILD_ITS_CLASSIFIER=true

# Mettre true pour (re)télécharger les fichiers de référence.
DOWNLOAD_16S_SILVA=true
DOWNLOAD_ITS_UNITE=true

# SILVA : la fonction q2-rescript get-silva-data télécharge les fichiers
# nécessaires. 138.2 est une version stable largement employée ; remplacez-la
# uniquement si votre installation q2-rescript liste une version plus récente.
SILVA_VERSION="138.2"
SILVA_TARGET="SSURef_NR99"

# UNITE : version actuellement publiée comme "Current" au moment de l'écriture
# du script. Le DOI mène au paquet QIIME officiel Fungi contenant les fichiers
# QZA de séquences et taxonomie (jeu dynamique, RefS, singletons inclus).
UNITE_VERSION="10.0_2025-02-19"
UNITE_DOI_URL="https://doi.org/10.15156/BIO/3301241"

# Amorces réellement utilisées dans le projet.
PRIMER_F_16S="GTGCCAGCMGCCGCGGTAA"      # 515F
PRIMER_R_16S="GGACTACHVGGGTWTCTAAT"      # 806R
PRIMER_F_ITS="GTGARTCATCGAATCTTTG"        # ITS7
PRIMER_R_ITS="TCCTCCGCTTATTGATATGC"       # ITS4

# Paramètres extraction des références.
PRIMER_IDENTITY_16S=0.80
PRIMER_IDENTITY_ITS=0.80
MIN_LENGTH_16S=100
MIN_LENGTH_ITS=50

# Paramètres de classification. La confiance 0.70 est le défaut QIIME 2.
TAXONOMY_CONFIDENCE=0.70
READS_PER_BATCH="auto"

# ------------------------------ INITIALISATION ------------------------------
CONDA_BASE="$(conda info --base 2>/dev/null || true)"
if [[ -z "${CONDA_BASE}" || ! -f "${CONDA_BASE}/etc/profile.d/conda.sh" ]]; then
  echo "ERREUR : Conda est introuvable. Chargez Miniconda/Anaconda avant de lancer ce script." >&2
  exit 1
fi
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate "${QIIME2_ENV}"
command -v qiime >/dev/null 2>&1 || { echo "ERREUR : qiime introuvable dans ${QIIME2_ENV}" >&2; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "ERREUR : curl est requis pour télécharger UNITE." >&2; exit 1; }

mkdir -p "${TMPDIR_BASE}" "${LOG_DIR}"
export TMPDIR="${TMPDIR_BASE}"

log() {
  printf '[%(%F %T)T] %s\n' -1 "$*" | tee -a "${LOG_DIR}/taxonomy_2025.7.log"
}

die() {
  log "ERREUR : $*"
  exit 1
}

require_file() {
  [[ -s "$1" ]] || die "Fichier absent ou vide : $1"
}

# q2-rescript est livré dans la distribution amplicon, mais cette vérification
# donne une erreur explicite s'il n'est pas présent dans l'environnement.
qiime rescript --help >/dev/null 2>&1 || die "Plugin q2-rescript absent de ${QIIME2_ENV}. Vérifiez l'installation de QIIME 2 amplicon 2025.7."

# Vérifier les actions disponibles avec les versions réellement installées.
qiime feature-classifier extract-reads --help >/dev/null
qiime feature-classifier fit-classifier-naive-bayes --help >/dev/null
qiime feature-classifier classify-sklearn --help >/dev/null

# =============================================================================
# FONCTIONS GENERIQUES
# =============================================================================
setup_marker_paths() {
  local marker="$1"
  local marker_lc
  marker_lc="$(tr '[:upper:]' '[:lower:]' <<< "${marker}")"

  MARKER_DIR="${RESULTS_DIR}/${marker_lc}"
  CORE_DIR="${MARKER_DIR}/05_qiime2/core"
  METADATA="${MARKER_DIR}/04_database_files/sample-metadata_${marker_lc}.tsv"
  TAX_DIR="${MARKER_DIR}/05_qiime2/taxonomy"
  DB_DIR="${TAX_DIR}/database"
  CLASSIFIER_DIR="${TAX_DIR}/classifier"
  RESULT_DIR="${TAX_DIR}/results"
  EXPORT_DIR="${MARKER_DIR}/05_qiime2/export/taxonomy"

  TABLE_QZA="${CORE_DIR}/table.qza"
  REP_SEQS_QZA="${CORE_DIR}/rep-seqs.qza"

  mkdir -p "${DB_DIR}" "${CLASSIFIER_DIR}" "${RESULT_DIR}" "${EXPORT_DIR}"
  require_file "${TABLE_QZA}"
  require_file "${REP_SEQS_QZA}"
  require_file "${METADATA}"
}

make_taxonomy_outputs() {
  local marker="$1"
  local taxonomy_qza="$2"
  local prefix="$3"

  log "${marker}: visualisation et barplot taxonomique"
  qiime metadata tabulate \
    --m-input-file "${taxonomy_qza}" \
    --o-visualization "${RESULT_DIR}/${prefix}_taxonomy.qzv"

  qiime taxa barplot \
    --i-table "${TABLE_QZA}" \
    --i-taxonomy "${taxonomy_qza}" \
    --m-metadata-file "${METADATA}" \
    --o-visualization "${RESULT_DIR}/${prefix}_taxa-barplot.qzv"

  rm -rf \
    "${EXPORT_DIR}/${prefix}_taxonomy" \
    "${EXPORT_DIR}/${prefix}_taxonomy_qzv" \
    "${EXPORT_DIR}/${prefix}_taxa_barplot"

  qiime tools export \
    --input-path "${taxonomy_qza}" \
    --output-path "${EXPORT_DIR}/${prefix}_taxonomy"

  qiime tools export \
    --input-path "${RESULT_DIR}/${prefix}_taxonomy.qzv" \
    --output-path "${EXPORT_DIR}/${prefix}_taxonomy_qzv"

  qiime tools export \
    --input-path "${RESULT_DIR}/${prefix}_taxa-barplot.qzv" \
    --output-path "${EXPORT_DIR}/${prefix}_taxa_barplot"
}

# =============================================================================
# 16S V4 : SILVA
# =============================================================================
setup_marker_paths "16S"

SILVA_RNA_SEQS="${DB_DIR}/silva-${SILVA_VERSION}-ssu-nr99-rna-seqs.qza"
SILVA_DNA_SEQS="${DB_DIR}/silva-${SILVA_VERSION}-ssu-nr99-dna-seqs.qza"
SILVA_TAX="${DB_DIR}/silva-${SILVA_VERSION}-ssu-nr99-tax.qza"
SILVA_V4_SEQS="${DB_DIR}/silva-${SILVA_VERSION}-515F-806R-seqs.qza"
SILVA_V4_UNIQ_SEQS="${DB_DIR}/silva-${SILVA_VERSION}-515F-806R-uniq-seqs.qza"
SILVA_V4_UNIQ_TAX="${DB_DIR}/silva-${SILVA_VERSION}-515F-806R-uniq-tax.qza"
SILVA_CLASSIFIER="${CLASSIFIER_DIR}/silva-${SILVA_VERSION}-515F-806R-naive-bayes-classifier.qza"
SILVA_TAXONOMY="${RESULT_DIR}/16S_SILVA_${SILVA_VERSION}_515F-806R_taxonomy.qza"

log "16S : table = ${TABLE_QZA}"
log "16S : rep-seqs = ${REP_SEQS_QZA}"

if [[ "${DOWNLOAD_16S_SILVA}" == true ]]; then
  log "16S : téléchargement SILVA ${SILVA_VERSION}, cible ${SILVA_TARGET}, via q2-rescript"
  rm -f "${SILVA_RNA_SEQS}" "${SILVA_DNA_SEQS}" "${SILVA_TAX}"
  qiime rescript get-silva-data \
    --p-version "${SILVA_VERSION}" \
    --p-target "${SILVA_TARGET}" \
    --o-silva-sequences "${SILVA_RNA_SEQS}" \
    --o-silva-taxonomy "${SILVA_TAX}"

  # Le classifieur exige des séquences ADN. Les séquences SILVA téléchargées
  # par RESCRIPt peuvent être en ARN : conversion U -> T avant extraction.
  qiime rescript reverse-transcribe \
    --i-rna-sequences "${SILVA_RNA_SEQS}" \
    --o-dna-sequences "${SILVA_DNA_SEQS}"
fi

require_file "${SILVA_DNA_SEQS}"
require_file "${SILVA_TAX}"

if [[ "${REBUILD_16S_CLASSIFIER}" == true ]]; then
  log "16S : extraction in silico SILVA avec 515F/806R (V4)"
  rm -f "${SILVA_V4_SEQS}" "${SILVA_V4_UNIQ_SEQS}" "${SILVA_V4_UNIQ_TAX}" "${SILVA_CLASSIFIER}"

  qiime feature-classifier extract-reads \
    --i-sequences "${SILVA_DNA_SEQS}" \
    --p-f-primer "${PRIMER_F_16S}" \
    --p-r-primer "${PRIMER_R_16S}" \
    --p-identity "${PRIMER_IDENTITY_16S}" \
    --p-min-length "${MIN_LENGTH_16S}" \
    --p-n-jobs "${THREADS}" \
    --p-read-orientation forward \
    --o-reads "${SILVA_V4_SEQS}"

  log "16S : dé-réplication séquence/taxonomie SILVA extraite"
  qiime rescript dereplicate \
    --i-sequences "${SILVA_V4_SEQS}" \
    --i-taxa "${SILVA_TAX}" \
    --p-mode uniq \
    --o-dereplicated-sequences "${SILVA_V4_UNIQ_SEQS}" \
    --o-dereplicated-taxa "${SILVA_V4_UNIQ_TAX}"

  log "16S : entraînement du classifieur naïf de Bayes SILVA-V4"
  qiime feature-classifier fit-classifier-naive-bayes \
    --i-reference-reads "${SILVA_V4_UNIQ_SEQS}" \
    --i-reference-taxonomy "${SILVA_V4_UNIQ_TAX}" \
    --o-classifier "${SILVA_CLASSIFIER}"
fi

require_file "${SILVA_CLASSIFIER}"
log "16S : assignation taxonomique des ASV"
rm -f "${SILVA_TAXONOMY}"
qiime feature-classifier classify-sklearn \
  --i-reads "${REP_SEQS_QZA}" \
  --i-classifier "${SILVA_CLASSIFIER}" \
  --p-n-jobs "${THREADS}" \
  --p-reads-per-batch "${READS_PER_BATCH}" \
  --p-confidence "${TAXONOMY_CONFIDENCE}" \
  --p-read-orientation auto \
  --o-classification "${SILVA_TAXONOMY}"

make_taxonomy_outputs "16S" "${SILVA_TAXONOMY}" "16S_SILVA_${SILVA_VERSION}_515F-806R"

# Export des références et du classifieur pour archivage reproductible.
rm -rf "${EXPORT_DIR}/database" "${EXPORT_DIR}/classifier"
mkdir -p "${EXPORT_DIR}/database" "${EXPORT_DIR}/classifier"
qiime tools export --input-path "${SILVA_V4_UNIQ_SEQS}" --output-path "${EXPORT_DIR}/database/silva_515F_806R_uniq_seqs"
qiime tools export --input-path "${SILVA_V4_UNIQ_TAX}" --output-path "${EXPORT_DIR}/database/silva_515F_806R_uniq_tax"
qiime tools export --input-path "${SILVA_CLASSIFIER}" --output-path "${EXPORT_DIR}/classifier/silva_515F_806R_naive_bayes"

# =============================================================================
# ITS : UNITE v10.0 (19-02-2025), Fungi, jeu dynamique / RefS
# =============================================================================
setup_marker_paths "ITS"

UNITE_ARCHIVE="${DB_DIR}/UNITE_${UNITE_VERSION}_fungi_dynamic_refs.qza.zip"
UNITE_UNPACKED="${DB_DIR}/unite_download"
UNITE_SEQS="${DB_DIR}/unite-${UNITE_VERSION}-fungi-dynamic-refs-seqs.qza"
UNITE_TAX="${DB_DIR}/unite-${UNITE_VERSION}-fungi-dynamic-refs-tax.qza"
UNITE_ITS_SEQS="${DB_DIR}/unite-${UNITE_VERSION}-ITS7-ITS4-seqs.qza"
UNITE_ITS_UNIQ_SEQS="${DB_DIR}/unite-${UNITE_VERSION}-ITS7-ITS4-uniq-seqs.qza"
UNITE_ITS_UNIQ_TAX="${DB_DIR}/unite-${UNITE_VERSION}-ITS7-ITS4-uniq-tax.qza"
UNITE_CLASSIFIER="${CLASSIFIER_DIR}/unite-${UNITE_VERSION}-ITS7-ITS4-naive-bayes-classifier.qza"
UNITE_TAXONOMY="${RESULT_DIR}/ITS_UNITE_${UNITE_VERSION}_ITS7-ITS4_taxonomy.qza"

log "ITS : table = ${TABLE_QZA}"
log "ITS : rep-seqs = ${REP_SEQS_QZA}"

if [[ "${DOWNLOAD_ITS_UNITE}" == true ]]; then
  log "ITS : téléchargement de UNITE ${UNITE_VERSION} (Fungi, QIIME release)"
  rm -rf "${UNITE_UNPACKED}"
  rm -f "${UNITE_ARCHIVE}" "${UNITE_SEQS}" "${UNITE_TAX}"
  mkdir -p "${UNITE_UNPACKED}"

  # Le DOI officiel redirige vers l'archive de la distribution QIIME UNITE.
  # curl -L conserve la redirection DOI ; unzip extrait les deux artefacts QZA.
  curl --fail --location --retry 3 --output "${UNITE_ARCHIVE}" "${UNITE_DOI_URL}"
  unzip -q "${UNITE_ARCHIVE}" -d "${UNITE_UNPACKED}"

  mapfile -t unite_qza < <(find "${UNITE_UNPACKED}" -type f -name '*.qza' | sort)
  (( ${#unite_qza[@]} >= 2 )) || die "UNITE : au moins deux artefacts .qza (séquences + taxonomie) étaient attendus après téléchargement."

  # Identification robuste à partir du type sémantique de chaque artefact,
  # plutôt que d'hypothèses sur le nom interne de l'archive UNITE.
  found_seqs=""
  found_tax=""
  for artifact in "${unite_qza[@]}"; do
    info="$(qiime tools peek "${artifact}")"
    if grep -q 'FeatureData\[Sequence\]' <<< "${info}"; then
      found_seqs="${artifact}"
    elif grep -q 'FeatureData\[Taxonomy\]' <<< "${info}"; then
      found_tax="${artifact}"
    fi
  done

  [[ -n "${found_seqs}" ]] || die "UNITE : artefact FeatureData[Sequence] introuvable dans l'archive."
  [[ -n "${found_tax}" ]] || die "UNITE : artefact FeatureData[Taxonomy] introuvable dans l'archive."
  cp -f "${found_seqs}" "${UNITE_SEQS}"
  cp -f "${found_tax}" "${UNITE_TAX}"
fi

require_file "${UNITE_SEQS}"
require_file "${UNITE_TAX}"

if [[ "${REBUILD_ITS_CLASSIFIER}" == true ]]; then
  log "ITS : extraction in silico UNITE avec ITS7/ITS4"
  rm -f "${UNITE_ITS_SEQS}" "${UNITE_ITS_UNIQ_SEQS}" "${UNITE_ITS_UNIQ_TAX}" "${UNITE_CLASSIFIER}"

  qiime feature-classifier extract-reads \
    --i-sequences "${UNITE_SEQS}" \
    --p-f-primer "${PRIMER_F_ITS}" \
    --p-r-primer "${PRIMER_R_ITS}" \
    --p-identity "${PRIMER_IDENTITY_ITS}" \
    --p-min-length "${MIN_LENGTH_ITS}" \
    --p-n-jobs "${THREADS}" \
    --p-read-orientation both \
    --o-reads "${UNITE_ITS_SEQS}"

  log "ITS : dé-réplication séquence/taxonomie UNITE extraite"
  qiime rescript dereplicate \
    --i-sequences "${UNITE_ITS_SEQS}" \
    --i-taxa "${UNITE_TAX}" \
    --p-mode uniq \
    --o-dereplicated-sequences "${UNITE_ITS_UNIQ_SEQS}" \
    --o-dereplicated-taxa "${UNITE_ITS_UNIQ_TAX}"

  log "ITS : entraînement du classifieur naïf de Bayes UNITE"
  qiime feature-classifier fit-classifier-naive-bayes \
    --i-reference-reads "${UNITE_ITS_UNIQ_SEQS}" \
    --i-reference-taxonomy "${UNITE_ITS_UNIQ_TAX}" \
    --o-classifier "${UNITE_CLASSIFIER}"
fi

require_file "${UNITE_CLASSIFIER}"
log "ITS : assignation taxonomique des ASV"
rm -f "${UNITE_TAXONOMY}"
qiime feature-classifier classify-sklearn \
  --i-reads "${REP_SEQS_QZA}" \
  --i-classifier "${UNITE_CLASSIFIER}" \
  --p-n-jobs "${THREADS}" \
  --p-reads-per-batch "${READS_PER_BATCH}" \
  --p-confidence "${TAXONOMY_CONFIDENCE}" \
  --p-read-orientation auto \
  --o-classification "${UNITE_TAXONOMY}"

make_taxonomy_outputs "ITS" "${UNITE_TAXONOMY}" "ITS_UNITE_${UNITE_VERSION}_ITS7-ITS4"

rm -rf "${EXPORT_DIR}/database" "${EXPORT_DIR}/classifier"
mkdir -p "${EXPORT_DIR}/database" "${EXPORT_DIR}/classifier"
qiime tools export --input-path "${UNITE_ITS_UNIQ_SEQS}" --output-path "${EXPORT_DIR}/database/unite_ITS7_ITS4_uniq_seqs"
qiime tools export --input-path "${UNITE_ITS_UNIQ_TAX}" --output-path "${EXPORT_DIR}/database/unite_ITS7_ITS4_uniq_tax"
qiime tools export --input-path "${UNITE_CLASSIFIER}" --output-path "${EXPORT_DIR}/classifier/unite_ITS7_ITS4_naive_bayes"

log "Terminé avec succès."
log "16S : ${RESULTS_DIR}/16s/05_qiime2/taxonomy/results"
log "ITS : ${RESULTS_DIR}/its/05_qiime2/taxonomy/results"
