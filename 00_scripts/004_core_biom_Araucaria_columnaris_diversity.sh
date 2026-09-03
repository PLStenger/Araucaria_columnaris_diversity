#!/usr/bin/env bash
# =============================================================================
# RAREFACTION + CORE METRICS + EXPORT TSV DES RESULTATS QIIME2
# Projet : Araucaria_columnaris_diversity
#
# Script adapte aux artefacts produits par :
# 001_pipeline_QIIME2_PE_Araucaria_columnaris_diversity.sh
#
# Le pipeline source produit, pour chaque marqueur :
#   02_amplicon_pipeline/<marqueur>/05_qiime2/core/table.qza
#   02_amplicon_pipeline/<marqueur>/05_qiime2/core/rep-seqs.qza
#   02_amplicon_pipeline/<marqueur>/05_qiime2/tree/rooted-tree.qza
#   02_amplicon_pipeline/<marqueur>/04_database_files/sample-metadata_<marqueur>.tsv
#
# Ce script traite separement les marqueurs 16S et ITS :
# 1. rarefaction explicite de la table ASV ;
# 2. calcul des core metrics (alpha, beta, PCoA et Emperor) ;
# 3. export de la table rarefiee QZA -> BIOM -> TSV ;
# 4. export des metriques alpha, matrices beta, PCoA, Emperor et taxonomie
#    si celle-ci est disponible.
#
# IMPORTANT : aucune table de taxonomie n'est produite par le script 001.
# Si taxonomy.qza existe deja pour un marqueur, elle sera exportee. Sinon,
# l'export taxonomique est ignore sans interrompre le pipeline.
#
# ATTENTION : qiime feature-table rarefy est aleatoire. Chaque execution avec
# RUN_RAREFY=true produit potentiellement une table rarefiee differente.
# Conserver les .qza obtenus, ou passer RUN_RAREFY=false pour les reutiliser.
# =============================================================================

set -Eeuo pipefail
shopt -s nullglob
IFS=$'\n\t'

# ==================== CONFIGURATION ====================

PROJECT_NAME="Araucaria_columnaris_diversity"
PROJECT_DIR="/nvme/bio/data_fungi/${PROJECT_NAME}"
RESULTS_DIR="${PROJECT_DIR}/02_amplicon_pipeline"
TMPDIR_BASE="${PROJECT_DIR}/tmp"

QIIME_ENV="qiime2-amplicon-2025.7"
BIOM_ENV="biom-format"

# Marqueurs a traiter. Les dossiers attendus sont en minuscules : 16s et its.
MARKERS=("16S" "ITS")

# Profondeurs de rarefaction imposees par marqueur.
SAMPLING_DEPTH_16S=2119
SAMPLING_DEPTH_ITS=6255

# -----------------------------------------------------------------------------
# MEMO — ECHANTILLONS EXCLUS PAR LA RAREFACTION
#
# 16S : profondeur de rarefaction = 2 119 reads/echantillon.
# Ces echantillons seront supprimes car leur nombre de reads est inferieur a
# cette profondeur :
# - Ac-NEG-T11-1 : 1 752 reads
# - Ac-B-Tneg-1A-T11-1 : 2 429 reads
# - Ac-B-Tneg-2A-T11-1 : 2 138 reads
# - Ac-C-Tpos-2A-T11-1 : 21 reads
# - Ac-A-D1-1B-T11-1 : 10 reads
# - Ac-C-D1-2A-T11-1 : 20 reads
#
# ITS : profondeur de rarefaction = 6 255 reads/echantillon.
# Ces echantillons seront supprimes car leur nombre de reads est inferieur a
# cette profondeur :
# - Ac-C-Tpos-2B-T11-1 : 25 882 reads
# - Ac-NEG-T11-1 : 11 600 reads
# - Ac-A-D1-2A-T11-1 : 1 630 reads
# - Ac-C-Tneg-2B-T11-1 : 2 237 reads
#
# NOTE IMPORTANTE : les deux premiers echantillons ITS listes ci-dessus ont un
# nombre de reads superieur a 6 255. Ils ne seront donc PAS exclus par la seule
# rarefaction QIIME2 a 6 255 reads. Ils sont conserves par le present script,
# sauf si vous activez explicitement EXCLUDE_LISTED_SAMPLES_ITS=true ci-dessous.
# -----------------------------------------------------------------------------

# false (recommande) : QIIME2 applique uniquement le critere de profondeur.
# true : retire aussi explicitement les quatre echantillons ITS listes ci-dessus
# avant la rarefaction, y compris ceux ayant > 6 255 reads.
EXCLUDE_LISTED_SAMPLES_ITS=false
ITS_SAMPLES_TO_EXCLUDE=(
    "Ac-C-Tpos-2B-T11-1"
    "Ac-NEG-T11-1"
    "Ac-A-D1-2A-T11-1"
    "Ac-C-Tneg-2B-T11-1"
)

# true : refait la rarefaction et ecrase la table rarefiee existante.
# false : reutilise la table rarefiee existante.
RUN_RAREFY=true

# true : recalcule core-metrics-phylogenetic et ecrase le repertoire existant.
# false : reutilise les core metrics deja calcules.
RUN_CORE_METRICS=true

# true : exporte les artefacts QIIME2 au format exploitable hors QIIME2.
RUN_EXPORT=true

# ==================== FONCTIONS ====================

log() {
    printf '[%(%F %T)T] %s\n' -1 "$*" | tee -a "${LOG_FILE}"
}

die() {
    log "ERREUR : $*"
    exit 1
}

trap 'rc=$?; log "ERREUR : code ${rc}, ligne ${LINENO} : ${BASH_COMMAND}"; exit "${rc}"' ERR

marker_to_lower() {
    tr '[:upper:]' '[:lower:]' <<< "$1"
}

qiime_run() {
    conda run -n "${QIIME_ENV}" qiime "$@"
}

export_qza() {
    local artifact="$1"
    local destination="$2"

    [[ -f "${artifact}" ]] || die "Artefact QIIME2 absent : ${artifact}"

    rm -rf "${destination}"
    mkdir -p "${destination}"

    log "Export QIIME2 : $(basename "${artifact}")"
    qiime_run tools export \
        --input-path "${artifact}" \
        --output-path "${destination}"
}

set_marker_variables() {
    local marker="$1"
    local marker_lc

    marker_lc="$(marker_to_lower "${marker}")"

    MARKER_DIR="${RESULTS_DIR}/${marker_lc}"
    DATABASE_DIR="${MARKER_DIR}/04_database_files"
    QIIME_DIR="${MARKER_DIR}/05_qiime2"
    QIIME_CORE_DIR="${QIIME_DIR}/core"
    QIIME_TREE_DIR="${QIIME_DIR}/tree"
    QIIME_EXPORT_DIR="${QIIME_DIR}/export"
    LOG_DIR="${RESULTS_DIR}/logs"
    LOG_FILE="${LOG_DIR}/04_core_biom_${marker_lc}.log"

    INPUT_TABLE="${QIIME_CORE_DIR}/table.qza"
    ROOTED_TREE="${QIIME_TREE_DIR}/rooted-tree.qza"
    METADATA="${DATABASE_DIR}/sample-metadata_${marker_lc}.tsv"
    TAXONOMY="${QIIME_CORE_DIR}/taxonomy.qza"

    case "${marker}" in
        16S)
            SAMPLING_DEPTH="${SAMPLING_DEPTH_16S}"
            ;;
        ITS)
            SAMPLING_DEPTH="${SAMPLING_DEPTH_ITS}"
            ;;
        *)
            die "Marqueur non supporte : ${marker}"
            ;;
    esac

    WORKING_TABLE="${INPUT_TABLE}"
    FILTERED_TABLE="${QIIME_CORE_DIR}/table_explicitly_filtered_before_rarefaction.qza"
    RAREFIED_TABLE="${QIIME_CORE_DIR}/RarTable_depth${SAMPLING_DEPTH}.qza"
    CORE_METRICS_DIR="${QIIME_CORE_DIR}/core-metrics-depth${SAMPLING_DEPTH}"
    EXPORT_CORE_DIR="${QIIME_EXPORT_DIR}/core-metrics-depth${SAMPLING_DEPTH}"
    EXPORT_TAXONOMY_DIR="${QIIME_EXPORT_DIR}/taxonomy"
    EXPORT_VISUAL_DIR="${QIIME_EXPORT_DIR}/visual/core-metrics-depth${SAMPLING_DEPTH}"
}

check_artifact() {
    local artifact="$1"
    [[ -f "${artifact}" ]] || die "Artefact QIIME2 absent : ${artifact}"
}

# ==================== INITIALISATION ====================

mkdir -p "${RESULTS_DIR}" "${RESULTS_DIR}/logs" "${TMPDIR_BASE}"
export TMPDIR="${TMPDIR_BASE}"

command -v conda >/dev/null 2>&1 || {
    echo "ERREUR : Conda est introuvable dans le PATH." >&2
    exit 1
}

conda run -n "${QIIME_ENV}" qiime --version >/dev/null \
    || { echo "ERREUR : QIIME2 ne demarre pas dans ${QIIME_ENV}." >&2; exit 1; }

conda run -n "${BIOM_ENV}" biom --help >/dev/null \
    || { echo "ERREUR : biom est absent de l'environnement ${BIOM_ENV}." >&2; exit 1; }

# ==================== TRAITEMENT PAR MARQUEUR ====================

for marker in "${MARKERS[@]}"; do
    set_marker_variables "${marker}"

    mkdir -p \
        "${LOG_DIR}" \
        "${QIIME_CORE_DIR}" \
        "${QIIME_EXPORT_DIR}" \
        "${EXPORT_CORE_DIR}" \
        "${EXPORT_VISUAL_DIR}"

    log "================================================================"
    log "Debut du traitement ${marker}"
    log "Environnement QIIME2 : ${QIIME_ENV}"
    log "Environnement BIOM : ${BIOM_ENV}"
    log "Profondeur de rarefaction : ${SAMPLING_DEPTH} reads/echantillon"

    [[ -f "${INPUT_TABLE}" ]] || die "Table ASV source absente : ${INPUT_TABLE}"
    [[ -f "${ROOTED_TREE}" ]] || die "Arbre enracine absent : ${ROOTED_TREE}"
    [[ -f "${METADATA}" ]] || die "Metadata absentes : ${METADATA}"

    # ==================== 1. FILTRAGE EXPLICITE OPTIONNEL ITS ====================

    if [[ "${marker}" == "ITS" && "${EXCLUDE_LISTED_SAMPLES_ITS}" == true ]]; then
        log "ITS : exclusion explicite des echantillons listes dans ITS_SAMPLES_TO_EXCLUDE"
        rm -f "${FILTERED_TABLE}"

        exclude_args=()
        for sample_id in "${ITS_SAMPLES_TO_EXCLUDE[@]}"; do
            exclude_args+=(--p-exclude-ids "${sample_id}")
        done

        qiime_run feature-table filter-samples \
            --i-table "${INPUT_TABLE}" \
            "${exclude_args[@]}" \
            --o-filtered-table "${FILTERED_TABLE}"

        WORKING_TABLE="${FILTERED_TABLE}"
        log "ITS : table filtree disponible : ${WORKING_TABLE}"
    else
        WORKING_TABLE="${INPUT_TABLE}"
    fi

    # ==================== 2. RAREFACTION ====================

    if [[ "${RUN_RAREFY}" == true ]]; then
        rm -f "${RAREFIED_TABLE}"

        log "${marker}: rarefaction de $(basename "${WORKING_TABLE}") a ${SAMPLING_DEPTH} reads"
        qiime_run feature-table rarefy \
            --i-table "${WORKING_TABLE}" \
            --p-sampling-depth "${SAMPLING_DEPTH}" \
            --p-no-with-replacement \
            --o-rarefied-table "${RAREFIED_TABLE}"
    else
        log "${marker}: rarefaction desactivee ; reutilisation de ${RAREFIED_TABLE}"
    fi

    check_artifact "${RAREFIED_TABLE}"
    log "${marker}: table rarefiee disponible : ${RAREFIED_TABLE}"

    # ==================== 3. CORE METRICS ====================

    if [[ "${RUN_CORE_METRICS}" == true ]]; then
        rm -rf "${CORE_METRICS_DIR}"

        log "${marker}: calcul des core metrics phylogenetiques"
        qiime_run diversity core-metrics-phylogenetic \
            --i-phylogeny "${ROOTED_TREE}" \
            --i-table "${RAREFIED_TABLE}" \
            --p-sampling-depth "${SAMPLING_DEPTH}" \
            --m-metadata-file "${METADATA}" \
            --p-n-jobs-or-threads 1 \
            --output-dir "${CORE_METRICS_DIR}"
    else
        log "${marker}: calcul core metrics desactive ; reutilisation de ${CORE_METRICS_DIR}"
    fi

    for artifact in \
        "${CORE_METRICS_DIR}/faith_pd_vector.qza" \
        "${CORE_METRICS_DIR}/shannon_vector.qza" \
        "${CORE_METRICS_DIR}/evenness_vector.qza" \
        "${CORE_METRICS_DIR}/observed_features_vector.qza" \
        "${CORE_METRICS_DIR}/bray_curtis_distance_matrix.qza" \
        "${CORE_METRICS_DIR}/jaccard_distance_matrix.qza" \
        "${CORE_METRICS_DIR}/unweighted_unifrac_distance_matrix.qza" \
        "${CORE_METRICS_DIR}/weighted_unifrac_distance_matrix.qza" \
        "${CORE_METRICS_DIR}/bray_curtis_pcoa_results.qza" \
        "${CORE_METRICS_DIR}/jaccard_pcoa_results.qza" \
        "${CORE_METRICS_DIR}/unweighted_unifrac_pcoa_results.qza" \
        "${CORE_METRICS_DIR}/weighted_unifrac_pcoa_results.qza" \
        "${CORE_METRICS_DIR}/bray_curtis_emperor.qzv" \
        "${CORE_METRICS_DIR}/jaccard_emperor.qzv" \
        "${CORE_METRICS_DIR}/unweighted_unifrac_emperor.qzv" \
        "${CORE_METRICS_DIR}/weighted_unifrac_emperor.qzv"; do
        check_artifact "${artifact}"
    done

    # ==================== 4. EXPORTS ====================

    if [[ "${RUN_EXPORT}" == true ]]; then
        TABLE_EXPORT_DIR="${EXPORT_CORE_DIR}/rarefied_table"
        BIOM_TABLE="${TABLE_EXPORT_DIR}/feature-table.biom"
        TSV_TABLE="${TABLE_EXPORT_DIR}/table-from-biom.tsv"
        ASV_TABLE="${TABLE_EXPORT_DIR}/ASV.tsv"

        log "${marker}: export de la table ASV rarefiee"
        export_qza "${RAREFIED_TABLE}" "${TABLE_EXPORT_DIR}"
        [[ -f "${BIOM_TABLE}" ]] || die "Fichier BIOM absent apres export : ${BIOM_TABLE}"

        log "${marker}: conversion BIOM -> TSV"
        conda run -n "${BIOM_ENV}" biom convert \
            -i "${BIOM_TABLE}" \
            -o "${TSV_TABLE}" \
            --to-tsv

        sed '1d; s/^#OTU ID/ASV_ID/' "${TSV_TABLE}" > "${ASV_TABLE}"
        [[ -s "${ASV_TABLE}" ]] || die "Echec de creation de ${ASV_TABLE}"

        log "${marker}: export des metriques alpha"
        export_qza "${CORE_METRICS_DIR}/faith_pd_vector.qza" "${EXPORT_CORE_DIR}/faith_pd"
        export_qza "${CORE_METRICS_DIR}/shannon_vector.qza" "${EXPORT_CORE_DIR}/shannon"
        export_qza "${CORE_METRICS_DIR}/evenness_vector.qza" "${EXPORT_CORE_DIR}/evenness"
        export_qza "${CORE_METRICS_DIR}/observed_features_vector.qza" "${EXPORT_CORE_DIR}/observed_features"

        log "${marker}: export des distances beta et resultats PCoA"
        for artifact in \
            "${CORE_METRICS_DIR}/bray_curtis_distance_matrix.qza" \
            "${CORE_METRICS_DIR}/jaccard_distance_matrix.qza" \
            "${CORE_METRICS_DIR}/unweighted_unifrac_distance_matrix.qza" \
            "${CORE_METRICS_DIR}/weighted_unifrac_distance_matrix.qza" \
            "${CORE_METRICS_DIR}/bray_curtis_pcoa_results.qza" \
            "${CORE_METRICS_DIR}/jaccard_pcoa_results.qza" \
            "${CORE_METRICS_DIR}/unweighted_unifrac_pcoa_results.qza" \
            "${CORE_METRICS_DIR}/weighted_unifrac_pcoa_results.qza"; do
            artifact_name="$(basename "${artifact}" .qza)"
            export_qza "${artifact}" "${EXPORT_CORE_DIR}/${artifact_name}"
        done

        log "${marker}: export des visualisations Emperor"
        for qzv in \
            "${CORE_METRICS_DIR}/bray_curtis_emperor.qzv" \
            "${CORE_METRICS_DIR}/jaccard_emperor.qzv" \
            "${CORE_METRICS_DIR}/unweighted_unifrac_emperor.qzv" \
            "${CORE_METRICS_DIR}/weighted_unifrac_emperor.qzv"; do
            qzv_name="$(basename "${qzv}" .qzv)"
            export_qza "${qzv}" "${EXPORT_VISUAL_DIR}/${qzv_name}"
        done

        if [[ -f "${TAXONOMY}" ]]; then
            log "${marker}: export de la taxonomie"
            export_qza "${TAXONOMY}" "${EXPORT_TAXONOMY_DIR}"
            [[ -f "${EXPORT_TAXONOMY_DIR}/taxonomy.tsv" ]] \
                || die "taxonomy.tsv absent apres export : ${EXPORT_TAXONOMY_DIR}/taxonomy.tsv"
        else
            log "${marker}: taxonomy.qza absent ; export taxonomique ignore"
        fi
    fi

    log "${marker}: pipeline termine avec succes"
    log "${marker}: table rarefiee QIIME2 : ${RAREFIED_TABLE}"
    log "${marker}: table ASV TSV : ${EXPORT_CORE_DIR}/rarefied_table/ASV.tsv"
    log "${marker}: core metrics : ${CORE_METRICS_DIR}"
    log "${marker}: exports : ${EXPORT_CORE_DIR}"
done

echo "Pipeline 04_core_biom termine avec succes pour : ${MARKERS[*]}"
