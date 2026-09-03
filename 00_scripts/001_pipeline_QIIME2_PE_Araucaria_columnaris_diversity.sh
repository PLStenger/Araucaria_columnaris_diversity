#!/usr/bin/env bash
# =============================================================================
# Pipeline QIIME 2 paired-end multi-marqueurs
# Projet : Araucaria_columnaris_diversity
#
# Nouveaute : remplacement explicite des 24 paires 16S Tpos/Tneg T11-1 depuis
# 01_raw_data/Araucaria_reupload_16S_T11-1, avec renommage selon le numero S.
# Les FASTQ source re-uploades sont nommes Ac-<zone>-T-... et ne distinguent pas
# Tpos/Tneg dans leur nom. La table REUPLOAD_16S_MAP restaure cette information.
#
# Workflow par marqueur :
# remplacement/audit raw 16S -> FastQC/MultiQC raw -> Trimmomatic ->
# FastQC/MultiQC cleaned -> import QIIME 2 -> DADA2 -> visualisations/exports
# -> arbre phylogenetique ASV.
#
# AUCUN filtrage de contingence/decontam ni filtrage de prevalence des ASV
# n'est applique dans ce script.
# =============================================================================

set -Eeuo pipefail
shopt -s nullglob
IFS=$'\n\t'

export JAVA_HOME="${JAVA_HOME:-}"
export JAVA_LD_LIBRARY_PATH="${JAVA_LD_LIBRARY_PATH:-}"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}"

trap 'rc=$?; echo "[ERREUR] Code ${rc}, ligne ${LINENO}: ${BASH_COMMAND}" >&2; exit "${rc}"' ERR

# ------------------------------- CONFIGURATION ------------------------------
PROJECT_NAME="Araucaria_columnaris_diversity"
PROJECT_DIR="/nvme/bio/data_fungi/${PROJECT_NAME}"
RAW_ROOT_DIR="${PROJECT_DIR}/01_raw_data"
RESULTS_DIR="${PROJECT_DIR}/02_amplicon_pipeline"
TMPDIR_BASE="${PROJECT_DIR}/tmp"
LOG_DIR="${RESULTS_DIR}/logs"

THREADS=1
QIIME_THREADS=8
TRIMMOMATIC_HEAP="4G"

# Environnements Conda : adapter leurs noms si necessaire.
FASTQC_ENV="fastqc"
MULTIQC_ENV="multiqc"
TRIMMOMATIC_ENV="trimmomatic"
QIIME2_ENV="qiime2-amplicon-2025.7"
PYTHON_ENV="excel_tools"

# Adapters Trimmomatic. Mettre false si les adaptateurs ont deja ete retires.
TRIMMOMATIC_ADAPTERS=true
ADAPTER_FILE="${PROJECT_DIR}/99_softwares/adapters_sequences.fasta"

# Parametres Trimmomatic.
LEADING=30
TRAILING=30
SLIDINGWINDOW="26:30"
MINLEN=150

# Active/desactive les grandes etapes.
RUN_REPLACE_REUPLOADED_16S=true
RUN_FASTQC_RAW=true
RUN_TRIMMOMATIC=true
RUN_FASTQC_CLEAN=true
RUN_QIIME_IMPORT=true
RUN_DADA2=true
RUN_TREE=true
RUN_EXPORT=true

# Lorsque true, force Trimmomatic pour les 24 echantillons 16S remplaces,
# meme si d'anciens fichiers cleaned existent encore.
FORCE_RETRIM_REUPLOADED_16S=true

# Marqueurs a analyser. Chaque marqueur lit son propre sous-repertoire raw.
MARKERS=("16S" "ITS")

# Dossier contenant les 48 FASTQ re-uploades (24 paires) avec le label T ambigu.
REUPLOAD_16S_DIR="${RAW_ROOT_DIR}/Araucaria_reupload_16S_T11-1"

# Sauvegarde des anciens raw avant remplacement. Un repertoire date est cree.
RAW_BACKUP_ROOT="${RAW_ROOT_DIR}/backup_invalid_16S_T11-1"

# Parametres DADA2 16S V4 (515F/806R).
# Adapter trim-left/trunc-len apres consultation de demux.qzv.
DADA2_TRIM_LEFT_F_16S=0
DADA2_TRIM_LEFT_R_16S=0
DADA2_TRUNC_LEN_F_16S=0
DADA2_TRUNC_LEN_R_16S=0
DADA2_MAX_EE_F_16S=2
DADA2_MAX_EE_R_16S=2
DADA2_CHIM_METHOD_16S="consensus"

# Parametres DADA2 ITS2 (ITS7/ITS4).
DADA2_TRIM_LEFT_F_ITS=0
DADA2_TRIM_LEFT_R_ITS=0
DADA2_TRUNC_LEN_F_ITS=0
DADA2_TRUNC_LEN_R_ITS=0
DADA2_MAX_EE_F_ITS=2
DADA2_MAX_EE_R_ITS=2
DADA2_CHIM_METHOD_ITS="consensus"

# --------------------- TABLE DE CORRESPONDANCE RE-UPLOAD 16S ----------------
# Format : prefixe source local ambigu|prefixe cible biologique explicite.
# Les noms cible sont ceux attendus dans 01_raw_data/16S et par le pipeline.
REUPLOAD_16S_MAP=(
"Ac-A-T-1A-T11-1_S9|Ac-A-Tpos-1A-T11-1_S9"
"Ac-A-T-1B-T11-1_S10|Ac-A-Tpos-1B-T11-1_S10"
"Ac-A-T-2A-T11-1_S11|Ac-A-Tpos-2A-T11-1_S11"
"Ac-A-T-2B-T11-1_S12|Ac-A-Tpos-2B-T11-1_S12"
"Ac-A-T-1A-T11-1_S13|Ac-A-Tneg-1A-T11-1_S13"
"Ac-A-T-1B-T11-1_S14|Ac-A-Tneg-1B-T11-1_S14"
"Ac-A-T-2A-T11-1_S15|Ac-A-Tneg-2A-T11-1_S15"
"Ac-A-T-2B-T11-1_S16|Ac-A-Tneg-2B-T11-1_S16"
"Ac-B-T-1A-T11-1_S41|Ac-B-Tpos-1A-T11-1_S41"
"Ac-B-T-1B-T11-1_S42|Ac-B-Tpos-1B-T11-1_S42"
"Ac-B-T-2A-T11-1_S43|Ac-B-Tpos-2A-T11-1_S43"
"Ac-B-T-2B-T11-1_S44|Ac-B-Tpos-2B-T11-1_S44"
"Ac-B-T-1A-T11-1_S45|Ac-B-Tneg-1A-T11-1_S45"
"Ac-B-T-1B-T11-1_S46|Ac-B-Tneg-1B-T11-1_S46"
"Ac-B-T-2A-T11-1_S47|Ac-B-Tneg-2A-T11-1_S47"
"Ac-B-T-2B-T11-1_S48|Ac-B-Tneg-2B-T11-1_S48"
"Ac-C-T-1A-T11-1_S73|Ac-C-Tpos-1A-T11-1_S73"
"Ac-C-T-1B-T11-1_S74|Ac-C-Tpos-1B-T11-1_S74"
"Ac-C-T-2A-T11-1_S75|Ac-C-Tpos-2A-T11-1_S75"
"Ac-C-T-2B-T11-1_S76|Ac-C-Tpos-2B-T11-1_S76"
"Ac-C-T-1A-T11-1_S77|Ac-C-Tneg-1A-T11-1_S77"
"Ac-C-T-1B-T11-1_S78|Ac-C-Tneg-1B-T11-1_S78"
"Ac-C-T-2A-T11-1_S79|Ac-C-Tneg-2A-T11-1_S79"
"Ac-C-T-2B-T11-1_S80|Ac-C-Tneg-2B-T11-1_S80"
)

# -------------------------------- FONCTIONS ---------------------------------
log() {
  printf '[%(%F %T)T] %s\n' -1 "$*" | tee -a "${LOG_DIR}/pipeline.log"
}

die() {
  log "ERREUR : $*"
  exit 1
}

activate_env() {
  local env_name="$1"
  export JAVA_HOME="${JAVA_HOME:-}"
  export JAVA_LD_LIBRARY_PATH="${JAVA_LD_LIBRARY_PATH:-}"
  export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}"
  conda deactivate >/dev/null 2>&1 || true
  conda activate "${env_name}"
}

check_command() {
  command -v "$1" >/dev/null 2>&1 || die "Commande introuvable : $1"
}

marker_to_lower() {
  echo "$1" | tr '[:upper:]' '[:lower:]'
}

set_marker_variables() {
  local marker="$1"
  local marker_lc
  marker_lc="$(marker_to_lower "${marker}")"

  RAW_DIR="${RAW_ROOT_DIR}/${marker}"
  MARKER_DIR="${RESULTS_DIR}/${marker_lc}"
  QC_RAW_DIR="${MARKER_DIR}/01_qc_raw"
  CLEAN_DIR="${MARKER_DIR}/02_cleaned_data"
  QC_CLEAN_DIR="${MARKER_DIR}/03_qc_cleaned"
  DATABASE_DIR="${MARKER_DIR}/04_database_files"
  QIIME_DIR="${MARKER_DIR}/05_qiime2"
  QIIME_CORE="${QIIME_DIR}/core"
  QIIME_VISUAL="${QIIME_DIR}/visual"
  QIIME_TREE="${QIIME_DIR}/tree"
  QIIME_EXPORT="${QIIME_DIR}/export"

  SAMPLE_SHEET="${DATABASE_DIR}/samples_${marker_lc}.tsv"
  RAW_FASTQ_LIST="${DATABASE_DIR}/raw_fastq_list_${marker_lc}.txt"
  RAW_PAIRS_TSV="${DATABASE_DIR}/raw_pairs_${marker_lc}.tsv"
  MANIFEST="${DATABASE_DIR}/manifest_pe_${marker_lc}.tsv"
  METADATA="${DATABASE_DIR}/sample-metadata_${marker_lc}.tsv"

  case "${marker}" in
    16S)
      DADA2_TRIM_LEFT_F="${DADA2_TRIM_LEFT_F_16S}"
      DADA2_TRIM_LEFT_R="${DADA2_TRIM_LEFT_R_16S}"
      DADA2_TRUNC_LEN_F="${DADA2_TRUNC_LEN_F_16S}"
      DADA2_TRUNC_LEN_R="${DADA2_TRUNC_LEN_R_16S}"
      DADA2_MAX_EE_F="${DADA2_MAX_EE_F_16S}"
      DADA2_MAX_EE_R="${DADA2_MAX_EE_R_16S}"
      DADA2_CHIM_METHOD="${DADA2_CHIM_METHOD_16S}"
      ;;
    ITS)
      DADA2_TRIM_LEFT_F="${DADA2_TRIM_LEFT_F_ITS}"
      DADA2_TRIM_LEFT_R="${DADA2_TRIM_LEFT_R_ITS}"
      DADA2_TRUNC_LEN_F="${DADA2_TRUNC_LEN_F_ITS}"
      DADA2_TRUNC_LEN_R="${DADA2_TRUNC_LEN_R_ITS}"
      DADA2_MAX_EE_F="${DADA2_MAX_EE_F_ITS}"
      DADA2_MAX_EE_R="${DADA2_MAX_EE_R_ITS}"
      DADA2_CHIM_METHOD="${DADA2_CHIM_METHOD_ITS}"
      ;;
    *)
      die "Marqueur non supporte : ${marker}"
      ;;
  esac
}

make_marker_directories() {
  mkdir -p \
    "${QC_RAW_DIR}" \
    "${CLEAN_DIR}" \
    "${QC_CLEAN_DIR}" \
    "${DATABASE_DIR}" \
    "${QIIME_CORE}" \
    "${QIIME_VISUAL}" \
    "${QIIME_TREE}" \
    "${QIIME_EXPORT}"
}

normalize_fastq_id() {
  awk 'NR % 4 == 1 {
    id=$1
    sub(/^@/, "", id)
    sub(/\/[12]$/, "", id)
    print id
  }'
}

observed_read_number() {
  zcat "$1" | awk 'NR == 1 {
    split($2, a, ":")
    print a[1]
    exit
  }'
}

observed_index() {
  zcat "$1" | awk 'NR == 1 {
    split($2, a, ":")
    print a[4]
    exit
  }'
}

validate_paired_fastq() {
  local r1="$1"
  local r2="$2"
  local label="$3"
  local max_pairs="${4:-10000}"
  local r1_read r2_read r1_index r2_index tested bad

  [[ -s "${r1}" ]] || die "R1 absent ou vide pour ${label} : ${r1}"
  [[ -s "${r2}" ]] || die "R2 absent ou vide pour ${label} : ${r2}"
  gzip -t "${r1}"
  gzip -t "${r2}"

  r1_read="$(observed_read_number "${r1}")"
  r2_read="$(observed_read_number "${r2}")"
  r1_index="$(observed_index "${r1}")"
  r2_index="$(observed_index "${r2}")"

  [[ "${r1_read}" == "1" ]] || die "${label}: le FASTQ R1 ne porte pas le marqueur 1:N (observe : ${r1_read})"
  [[ "${r2_read}" == "2" ]] || die "${label}: le FASTQ R2 ne porte pas le marqueur 2:N (observe : ${r2_read})"
  [[ "${r1_index}" == "${r2_index}" ]] || die "${label}: indexes Illumina differents entre R1 (${r1_index}) et R2 (${r2_index})"

  read -r tested bad < <(
    paste \
      <(zcat "${r1}" | normalize_fastq_id) \
      <(zcat "${r2}" | normalize_fastq_id) \
    | awk -v n="${max_pairs}" '
        {
          if ($1 != $2) bad++
          tested++
          if (tested == n) {
            print tested, bad + 0
            printed = 1
            exit
          }
        }
        END {
          if (!printed) print tested + 0, bad + 0
        }
      '
  )

  (( tested > 0 )) || die "${label}: aucune paire lue pendant l'audit"
  (( bad == 0 )) || die "${label}: ${bad}/${tested} IDs de cluster R1/R2 discordants"

  log "Audit paired-end OK (${label}) : ${tested} paires, R1=1:N, R2=2:N, index=${r1_index}"
}

is_reuploaded_16s_sample() {
  local sample_id="$1"
  local entry source_prefix target_prefix
  for entry in "${REUPLOAD_16S_MAP[@]}"; do
    IFS='|' read -r source_prefix target_prefix <<< "${entry}"
    if [[ "${target_prefix}" =~ ^${sample_id}_S[0-9]+$ ]]; then
      return 0
    fi
  done
  return 1
}

run_fastqc_multiqc_from_list() {
  local input_list="$1"
  local output_dir="$2"
  local label="$3"
  local files=()

  mapfile -t files < "${input_list}"
  ((${#files[@]} > 0)) || die "Liste FastQC vide : ${input_list}"

  mkdir -p "${output_dir}/fastqc" "${output_dir}/multiqc"
  log "FastQC (${label}) sur ${#files[@]} fichiers"

  activate_env "${FASTQC_ENV}"
  check_command fastqc
  fastqc --threads "${THREADS}" --outdir "${output_dir}/fastqc" "${files[@]}"

  activate_env "${MULTIQC_ENV}"
  check_command multiqc
  multiqc --force --outdir "${output_dir}/multiqc" "${output_dir}/fastqc"
}

run_fastqc_multiqc_from_directory() {
  local input_dir="$1"
  local output_dir="$2"
  local label="$3"
  local files=("${input_dir}"/*.fastq.gz)

  ((${#files[@]} > 0)) || die "Aucun fichier *.fastq.gz dans ${input_dir}"

  mkdir -p "${output_dir}/fastqc" "${output_dir}/multiqc"
  log "FastQC (${label}) sur ${#files[@]} fichiers"

  activate_env "${FASTQC_ENV}"
  check_command fastqc
  fastqc --threads "${THREADS}" --outdir "${output_dir}/fastqc" "${files[@]}"

  activate_env "${MULTIQC_ENV}"
  check_command multiqc
  multiqc --force --outdir "${output_dir}/multiqc" "${output_dir}/fastqc"
}

# ---------------------------- INITIALISATION CONDA --------------------------
CONDA_BASE="$(conda info --base 2>/dev/null || true)"
if [[ -z "${CONDA_BASE}" || ! -f "${CONDA_BASE}/etc/profile.d/conda.sh" ]]; then
  echo "ERREUR : Conda est introuvable. Chargez Miniconda/Anaconda avant de lancer ce script." >&2
  exit 1
fi
source "${CONDA_BASE}/etc/profile.d/conda.sh"

mkdir -p "${RESULTS_DIR}" "${LOG_DIR}" "${TMPDIR_BASE}"
export TMPDIR="${TMPDIR_BASE}"

[[ -d "${RAW_ROOT_DIR}" ]] || die "Repertoire raw racine introuvable : ${RAW_ROOT_DIR}"
log "Demarrage du pipeline ${PROJECT_NAME}"
log "Raw root : ${RAW_ROOT_DIR}"
log "Marqueurs analyses : ${MARKERS[*]}"
log "Aucun filtrage de contingence/decontam ni de prevalence des ASV ne sera applique."

# =============================================================================
# 0. REMPLACEMENT DES FASTQ 16S T11-1 RE-UPLOADES
# =============================================================================
# Les fichiers re-uploades sont conserves dans leur dossier source. Ils sont
# copies vers 01_raw_data/16S avec le nom biologique explicite Tpos/Tneg.
# Les anciens fichiers sont sauvegardes avant ecrasement.
if [[ "${RUN_REPLACE_REUPLOADED_16S}" == true ]]; then
  RAW_16S_DIR="${RAW_ROOT_DIR}/16S"
  [[ -d "${RAW_16S_DIR}" ]] || die "Repertoire raw 16S absent : ${RAW_16S_DIR}"
  [[ -d "${REUPLOAD_16S_DIR}" ]] || die "Repertoire des FASTQ re-uploades absent : ${REUPLOAD_16S_DIR}"

  reupload_count=$(find "${REUPLOAD_16S_DIR}" -maxdepth 1 -type f -name '*.fastq.gz' | wc -l)
  (( reupload_count == 48 )) || die "48 FASTQ re-uploades attendus dans ${REUPLOAD_16S_DIR}, observes : ${reupload_count}"

  BACKUP_DIR="${RAW_BACKUP_ROOT}_$(date +%Y%m%d_%H%M%S)"
  mkdir -p "${BACKUP_DIR}"
  log "16S: remplacement des 24 paires re-uploades depuis ${REUPLOAD_16S_DIR}"

  for entry in "${REUPLOAD_16S_MAP[@]}"; do
    IFS='|' read -r source_prefix target_prefix <<< "${entry}"

    source_r1="${REUPLOAD_16S_DIR}/${source_prefix}_L001_R1_001.fastq.gz"
    source_r2="${REUPLOAD_16S_DIR}/${source_prefix}_L001_R2_001.fastq.gz"
    target_r1="${RAW_16S_DIR}/${target_prefix}_L001_R1_001.fastq.gz"
    target_r2="${RAW_16S_DIR}/${target_prefix}_L001_R2_001.fastq.gz"

    validate_paired_fastq "${source_r1}" "${source_r2}" "re-upload ${target_prefix}" 10000

    if [[ -e "${target_r1}" ]]; then
      cp -a "${target_r1}" "${BACKUP_DIR}/"
    fi
    if [[ -e "${target_r2}" ]]; then
      cp -a "${target_r2}" "${BACKUP_DIR}/"
    fi

    cp -f "${source_r1}" "${target_r1}"
    cp -f "${source_r2}" "${target_r2}"
    gzip -t "${target_r1}"
    gzip -t "${target_r2}"

    validate_paired_fastq "${target_r1}" "${target_r2}" "raw remplace ${target_prefix}" 10000
  done

  backup_count=$(find "${BACKUP_DIR}" -maxdepth 1 -type f -name '*.fastq.gz' | wc -l)
  (( backup_count == 48 )) || die "Sauvegarde raw incomplete : 48 FASTQ attendus, observes : ${backup_count} dans ${BACKUP_DIR}"
  log "16S: remplacement termine. Sauvegarde des anciens FASTQ : ${BACKUP_DIR}"
fi

# =============================================================================
# 1. INVENTAIRE DES FASTQ ET GENERATION DES MANIFESTS/METADATA
# =============================================================================
activate_env "${PYTHON_ENV}"
check_command python

for marker in "${MARKERS[@]}"; do
  set_marker_variables "${marker}"
  make_marker_directories

  [[ -d "${RAW_DIR}" ]] || die "Repertoire raw manquant pour ${marker} : ${RAW_DIR}"
  log "${marker}: lecture des FASTQ dans ${RAW_DIR}"

  python - \
    "${RAW_DIR}" \
    "${marker}" \
    "${SAMPLE_SHEET}" \
    "${RAW_FASTQ_LIST}" \
    "${RAW_PAIRS_TSV}" \
    "${MANIFEST}" \
    "${METADATA}" \
    "${CLEAN_DIR}" <<'PY'
import re
import sys
from pathlib import Path

import pandas as pd

raw_dir, marker, sample_sheet, raw_fastq_list, raw_pairs_tsv, manifest, metadata, clean_dir = sys.argv[1:]
raw_dir = Path(raw_dir)
clean_dir = Path(clean_dir)

fastqs = sorted(raw_dir.glob("*.fastq.gz"))
if not fastqs:
    raise SystemExit(f"Aucun FASTQ *.fastq.gz trouve pour {marker} dans {raw_dir}")

records = {}

for fq in fastqs:
    filename = fq.name
    match = re.match(r"^(?P<sample_id>.+)_S\d+_L\d{3}_R(?P<read>[12])_\d{3}\.fastq\.gz$", filename)
    if match is None:
        raise SystemExit(
            f"Nom FASTQ non reconnu : {filename}\n"
            "Format attendu, par exemple : "
            "Ac-A-D1-1A-T11-1_S25_L001_R1_001.fastq.gz"
        )

    sample_id = match.group("sample_id")
    direction = f"R{match.group('read')}"

    if sample_id in records and direction in records[sample_id]:
        raise SystemExit(
            f"Doublon detecte pour {sample_id} ({direction}) dans {raw_dir}. "
            "Un seul FASTQ R1 et un seul FASTQ R2 sont attendus par echantillon."
        )

    records.setdefault(sample_id, {})[direction] = str(fq.resolve())

rows = []

for sample_id, files in sorted(records.items()):
    if "R1" not in files or "R2" not in files:
        missing = ", ".join(direction for direction in ("R1", "R2") if direction not in files)
        raise SystemExit(f"Paire incomplete pour {sample_id} ({marker}) : {missing} absent(s)")

    parts = sample_id.split("-")

    if len(parts) == 6:
        tree, zone, treatment, sub_block, timepoint, year = parts

        if tree != "Ac":
            raise SystemExit(f"Prefixe arbre inattendu pour {sample_id} : {tree}")
        if zone not in {"A", "B", "C"}:
            raise SystemExit(f"Zone inattendue pour {sample_id} : {zone}")
        if not re.fullmatch(r"T\d+", timepoint):
            raise SystemExit(f"Temps inattendu pour {sample_id} : {timepoint}")
        if year not in {"1", "2"}:
            raise SystemExit(f"Annee inattendue pour {sample_id} : {year}")

        if treatment in {"Tpos", "Tneg"}:
            treatment_class = "control"
            depth = "NA"
        elif re.fullmatch(r"D\d+", treatment):
            treatment_class = "soil"
            depth = treatment
        else:
            raise SystemExit(
                f"Traitement inattendu pour {sample_id} : {treatment}. "
                "Valeurs attendues : D1, D2, Tpos ou Tneg."
            )

    elif len(parts) == 4 and parts[0] == "Ac" and parts[1] == "NEG":
        tree, zone, timepoint, year = parts
        treatment = "NEG"
        treatment_class = "extraction_blank"
        depth = "NA"
        sub_block = "NA"

        if not re.fullmatch(r"T\d+", timepoint):
            raise SystemExit(f"Temps inattendu pour {sample_id} : {timepoint}")
        if year not in {"1", "2"}:
            raise SystemExit(f"Annee inattendue pour {sample_id} : {year}")

    else:
        raise SystemExit(
            f"Nom d'echantillon non reconnu : {sample_id}. "
            "Formats attendus : Ac-A-D1-1A-T11-1 ou Ac-NEG-T11-1."
        )

    rows.append({
        "sample-id": sample_id,
        "marker": marker,
        "tree_species_code": tree,
        "zone": zone,
        "treatment": treatment,
        "treatment_class": treatment_class,
        "depth": depth,
        "sub_block": sub_block,
        "timepoint": timepoint,
        "month_code": timepoint,
        "year": year,
        "year_label": f"year_{year}",
        "R1": files["R1"],
        "R2": files["R2"],
    })

df = pd.DataFrame(rows)
if df.empty:
    raise SystemExit(f"Aucun echantillon valide pour {marker} dans {raw_dir}")

if df["sample-id"].duplicated().any():
    duplicates = df.loc[df["sample-id"].duplicated(keep=False), "sample-id"].tolist()
    raise SystemExit("Sample IDs dupliques : " + ", ".join(duplicates))

df.to_csv(sample_sheet, sep="\t", index=False, na_rep="")

raw_pairs = df[["sample-id", "R1", "R2"]].rename(columns={
    "R1": "raw-forward-absolute-filepath",
    "R2": "raw-reverse-absolute-filepath",
})
raw_pairs.to_csv(raw_pairs_tsv, sep="\t", index=False)

with open(raw_fastq_list, "w", encoding="utf-8") as handle:
    for path in raw_pairs["raw-forward-absolute-filepath"]:
        handle.write(path + "\n")
    for path in raw_pairs["raw-reverse-absolute-filepath"]:
        handle.write(path + "\n")

manifest_df = pd.DataFrame({
    "sample-id": df["sample-id"],
    "forward-absolute-filepath": [
        str(clean_dir / f"{sample_id}_R1_paired.fastq.gz")
        for sample_id in df["sample-id"]
    ],
    "reverse-absolute-filepath": [
        str(clean_dir / f"{sample_id}_R2_paired.fastq.gz")
        for sample_id in df["sample-id"]
    ],
})
manifest_df.to_csv(manifest, sep="\t", index=False)

metadata_df = df.drop(columns=["R1", "R2"]).rename(columns={"sample-id": "#SampleID"})
metadata_df.to_csv(metadata, sep="\t", index=False, na_rep="")

print(f"{marker}: {len(df)} echantillons ecrits")
print(f"{marker}: manifest = {manifest}")
print(f"{marker}: metadata = {metadata}")
PY

  [[ -s "${SAMPLE_SHEET}" ]] || die "Table d'audit absente ou vide pour ${marker}: ${SAMPLE_SHEET}"
  [[ -s "${RAW_FASTQ_LIST}" ]] || die "Liste FASTQ absente ou vide pour ${marker}: ${RAW_FASTQ_LIST}"
  [[ -s "${RAW_PAIRS_TSV}" ]] || die "Table des paires absente ou vide pour ${marker}: ${RAW_PAIRS_TSV}"
  [[ -s "${MANIFEST}" ]] || die "Manifest absent ou vide pour ${marker}: ${MANIFEST}"
  [[ -s "${METADATA}" ]] || die "Metadata absentes ou vides pour ${marker}: ${METADATA}"

  N_SAMPLES=$(( $(wc -l < "${MANIFEST}") - 1 ))
  N_RAW_FASTQ=$(wc -l < "${RAW_FASTQ_LIST}")
  (( N_SAMPLES > 0 )) || die "Manifest vide pour ${marker}."
  (( N_RAW_FASTQ == N_SAMPLES * 2 )) || die "Nombre de FASTQ incoherent pour ${marker}."

  log "${marker}: ${N_SAMPLES} echantillons et ${N_RAW_FASTQ} FASTQ declares"
done

# =============================================================================
# 2. VERIFICATION ET AUDIT DES FASTQ BRUTS
# =============================================================================
for marker in "${MARKERS[@]}"; do
  set_marker_variables "${marker}"
  log "${marker}: verification de l'existence et de l'integrite gzip des FASTQ bruts"

  while IFS=$'\t' read -r sample_id raw_r1 raw_r2; do
    [[ "${sample_id}" == "sample-id" ]] && continue
    [[ -s "${raw_r1}" ]] || die "R1 introuvable ou vide pour ${sample_id} (${marker}) : ${raw_r1}"
    [[ -s "${raw_r2}" ]] || die "R2 introuvable ou vide pour ${sample_id} (${marker}) : ${raw_r2}"
    gzip -t "${raw_r1}"
    gzip -t "${raw_r2}"

    if [[ "${marker}" == "16S" ]] && is_reuploaded_16s_sample "${sample_id}"; then
      validate_paired_fastq "${raw_r1}" "${raw_r2}" "raw 16S ${sample_id}" 10000
    fi
  done < "${RAW_PAIRS_TSV}"
done

# =============================================================================
# 3. FASTQC / MULTIQC SUR LES READS BRUTS
# =============================================================================
if [[ "${RUN_FASTQC_RAW}" == true ]]; then
  for marker in "${MARKERS[@]}"; do
    set_marker_variables "${marker}"
    run_fastqc_multiqc_from_list "${RAW_FASTQ_LIST}" "${QC_RAW_DIR}" "reads bruts ${marker}"
  done
fi

# =============================================================================
# 4. TRIMMOMATIC PAIRED-END, SEPARE PAR MARQUEUR
# =============================================================================
if [[ "${RUN_TRIMMOMATIC}" == true ]]; then
  if [[ "${TRIMMOMATIC_ADAPTERS}" == true ]]; then
    [[ -f "${ADAPTER_FILE}" ]] || die "Fichier d'adaptateurs absent : ${ADAPTER_FILE}"
    TRIM_ADAPTER_ARG=("ILLUMINACLIP:${ADAPTER_FILE}:2:30:10")
  else
    TRIM_ADAPTER_ARG=()
  fi

  activate_env "${TRIMMOMATIC_ENV}"
  check_command trimmomatic

  for marker in "${MARKERS[@]}"; do
    set_marker_variables "${marker}"
    log "${marker}: Trimmomatic paired-end"

    while IFS=$'\t' read -r sample_id raw_r1 raw_r2; do
      [[ "${sample_id}" == "sample-id" ]] && continue

      out_r1_paired="${CLEAN_DIR}/${sample_id}_R1_paired.fastq.gz"
      out_r1_unpaired="${CLEAN_DIR}/${sample_id}_R1_unpaired.fastq.gz"
      out_r2_paired="${CLEAN_DIR}/${sample_id}_R2_paired.fastq.gz"
      out_r2_unpaired="${CLEAN_DIR}/${sample_id}_R2_unpaired.fastq.gz"

      force_retrim=false
      if [[ "${marker}" == "16S" && "${FORCE_RETRIM_REUPLOADED_16S}" == true ]] && is_reuploaded_16s_sample "${sample_id}"; then
        force_retrim=true
      fi

      if [[ "${force_retrim}" == false ]] \
        && [[ -s "${out_r1_paired}" && -s "${out_r2_paired}" ]] \
        && gzip -t "${out_r1_paired}" \
        && gzip -t "${out_r2_paired}"; then
        log "${marker}: Trimmomatic deja termine et fichiers gzip valides pour ${sample_id}"
        continue
      fi

      rm -f \
        "${out_r1_paired}" \
        "${out_r1_unpaired}" \
        "${out_r2_paired}" \
        "${out_r2_unpaired}"

      log "${marker}: Trimmomatic ${sample_id}"
      trimmomatic PE \
        -Xmx"${TRIMMOMATIC_HEAP}" \
        -threads "${THREADS}" \
        -phred33 \
        "${raw_r1}" \
        "${raw_r2}" \
        "${out_r1_paired}" \
        "${out_r1_unpaired}" \
        "${out_r2_paired}" \
        "${out_r2_unpaired}" \
        "${TRIM_ADAPTER_ARG[@]}" \
        "LEADING:${LEADING}" \
        "TRAILING:${TRAILING}" \
        "SLIDINGWINDOW:${SLIDINGWINDOW}" \
        "MINLEN:${MINLEN}"

      if [[ "${marker}" == "16S" ]] && is_reuploaded_16s_sample "${sample_id}"; then
        validate_paired_fastq "${out_r1_paired}" "${out_r2_paired}" "cleaned 16S ${sample_id}" 10000
      fi
    done < "${RAW_PAIRS_TSV}"
  done
fi

# Les manifests QIIME2 pointent vers les reads paired produits par Trimmomatic.
# Cette verification est donc obligatoire, y compris si RUN_TRIMMOMATIC=false.
for marker in "${MARKERS[@]}"; do
  set_marker_variables "${marker}"
  log "${marker}: verification des reads paired utilises par le manifest"

  while IFS=$'\t' read -r sample_id paired_r1 paired_r2; do
    [[ "${sample_id}" == "sample-id" ]] && continue
    [[ -s "${paired_r1}" ]] || die "R1 paired manquant pour ${sample_id} (${marker}) : ${paired_r1}. Activez RUN_TRIMMOMATIC=true ou fournissez ce fichier."
    [[ -s "${paired_r2}" ]] || die "R2 paired manquant pour ${sample_id} (${marker}) : ${paired_r2}. Activez RUN_TRIMMOMATIC=true ou fournissez ce fichier."
    gzip -t "${paired_r1}"
    gzip -t "${paired_r2}"

    if [[ "${marker}" == "16S" ]] && is_reuploaded_16s_sample "${sample_id}"; then
      validate_paired_fastq "${paired_r1}" "${paired_r2}" "manifest cleaned 16S ${sample_id}" 10000
    fi
  done < "${MANIFEST}"
done

# =============================================================================
# 5. FASTQC / MULTIQC APRES TRIMMOMATIC
# =============================================================================
if [[ "${RUN_FASTQC_CLEAN}" == true ]]; then
  for marker in "${MARKERS[@]}"; do
    set_marker_variables "${marker}"
    run_fastqc_multiqc_from_directory "${CLEAN_DIR}" "${QC_CLEAN_DIR}" "reads nettoyes ${marker}"
  done
fi

# =============================================================================
# 6. QIIME2 : IMPORT, DADA2, ARBRE ET EXPORTS PAR MARQUEUR
# =============================================================================
activate_env "${QIIME2_ENV}"
check_command qiime
export TMPDIR="${TMPDIR_BASE}"

for marker in "${MARKERS[@]}"; do
  set_marker_variables "${marker}"
  log "${marker}: debut du traitement QIIME2"

  if [[ "${RUN_QIIME_IMPORT}" == true ]]; then
    rm -f "${QIIME_CORE}/demux.qza" "${QIIME_VISUAL}/demux.qzv"
    log "${marker}: import QIIME2 paired-end"
    qiime tools import \
      --type 'SampleData[PairedEndSequencesWithQuality]' \
      --input-path "${MANIFEST}" \
      --input-format PairedEndFastqManifestPhred33V2 \
      --output-path "${QIIME_CORE}/demux.qza"

    qiime demux summarize \
      --i-data "${QIIME_CORE}/demux.qza" \
      --o-visualization "${QIIME_VISUAL}/demux.qzv"
  fi

  [[ -f "${QIIME_CORE}/demux.qza" ]] || die "demux.qza absent pour ${marker}: activez RUN_QIIME_IMPORT=true ou fournissez ce fichier."

  if [[ "${RUN_DADA2}" == true ]]; then
    rm -f \
      "${QIIME_CORE}/table.qza" \
      "${QIIME_CORE}/rep-seqs.qza" \
      "${QIIME_CORE}/denoising-stats.qza" \
      "${QIIME_VISUAL}/denoising-stats.qzv" \
      "${QIIME_VISUAL}/table.qzv" \
      "${QIIME_VISUAL}/rep-seqs.qzv"

    log "${marker}: denoising DADA2 paired-end"
    qiime dada2 denoise-paired \
      --i-demultiplexed-seqs "${QIIME_CORE}/demux.qza" \
      --p-trim-left-f "${DADA2_TRIM_LEFT_F}" \
      --p-trim-left-r "${DADA2_TRIM_LEFT_R}" \
      --p-trunc-len-f "${DADA2_TRUNC_LEN_F}" \
      --p-trunc-len-r "${DADA2_TRUNC_LEN_R}" \
      --p-max-ee-f "${DADA2_MAX_EE_F}" \
      --p-max-ee-r "${DADA2_MAX_EE_R}" \
      --p-chimera-method "${DADA2_CHIM_METHOD}" \
      --p-n-threads "${QIIME_THREADS}" \
      --o-table "${QIIME_CORE}/table.qza" \
      --o-representative-sequences "${QIIME_CORE}/rep-seqs.qza" \
      --o-denoising-stats "${QIIME_CORE}/denoising-stats.qza"

    qiime metadata tabulate \
      --m-input-file "${QIIME_CORE}/denoising-stats.qza" \
      --o-visualization "${QIIME_VISUAL}/denoising-stats.qzv"

    qiime feature-table summarize \
      --i-table "${QIIME_CORE}/table.qza" \
      --m-sample-metadata-file "${METADATA}" \
      --o-visualization "${QIIME_VISUAL}/table.qzv"

    qiime feature-table tabulate-seqs \
      --i-data "${QIIME_CORE}/rep-seqs.qza" \
      --o-visualization "${QIIME_VISUAL}/rep-seqs.qzv"
  fi

  [[ -f "${QIIME_CORE}/table.qza" ]] || die "table.qza absent pour ${marker}: activez RUN_DADA2=true ou fournissez ce fichier."
  [[ -f "${QIIME_CORE}/rep-seqs.qza" ]] || die "rep-seqs.qza absent pour ${marker}: activez RUNDADA2=true ou fournissez ce fichier."

  if [[ "${RUN_TREE}" == true ]]; then
    rm -f \
      "${QIIME_TREE}/aligned-rep-seqs.qza" \
      "${QIIME_TREE}/masked-aligned-rep-seqs.qza" \
      "${QIIME_TREE}/unrooted-tree.qza" \
      "${QIIME_TREE}/rooted-tree.qza"

    log "${marker}: construction de l'arbre ASV MAFFT -> mask -> FastTree -> midpoint root"
    qiime alignment mafft \
      --i-sequences "${QIIME_CORE}/rep-seqs.qza" \
      --p-n-threads "${QIIME_THREADS}" \
      --o-alignment "${QIIME_TREE}/aligned-rep-seqs.qza"

    qiime alignment mask \
      --i-alignment "${QIIME_TREE}/aligned-rep-seqs.qza" \
      --o-masked-alignment "${QIIME_TREE}/masked-aligned-rep-seqs.qza"

    qiime phylogeny fasttree \
      --i-alignment "${QIIME_TREE}/masked-aligned-rep-seqs.qza" \
      --o-tree "${QIIME_TREE}/unrooted-tree.qza"

    qiime phylogeny midpoint-root \
      --i-tree "${QIIME_TREE}/unrooted-tree.qza" \
      --o-rooted-tree "${QIIME_TREE}/rooted-tree.qza"
  fi

  if [[ "${RUN_EXPORT}" == true ]]; then
    log "${marker}: export des resultats QIIME2"
    rm -rf "${QIIME_EXPORT}/core" "${QIIME_EXPORT}/tree" "${QIIME_EXPORT}/visual"
    mkdir -p "${QIIME_EXPORT}/core" "${QIIME_EXPORT}/tree" "${QIIME_EXPORT}/visual"

    qiime tools export \
      --input-path "${QIIME_CORE}/table.qza" \
      --output-path "${QIIME_EXPORT}/core/table"

    qiime tools export \
      --input-path "${QIIME_CORE}/rep-seqs.qza" \
      --output-path "${QIIME_EXPORT}/core/rep-seqs"

    qiime tools export \
      --input-path "${QIIME_CORE}/denoising-stats.qza" \
      --output-path "${QIIME_EXPORT}/core/denoising-stats"

    if [[ -f "${QIIME_TREE}/rooted-tree.qza" ]]; then
      qiime tools export \
        --input-path "${QIIME_TREE}/aligned-rep-seqs.qza" \
        --output-path "${QIIME_EXPORT}/tree/aligned-rep-seqs"

      qiime tools export \
        --input-path "${QIIME_TREE}/masked-aligned-rep-seqs.qza" \
        --output-path "${QIIME_EXPORT}/tree/masked-aligned-rep-seqs"

      qiime tools export \
        --input-path "${QIIME_TREE}/unrooted-tree.qza" \
        --output-path "${QIIME_EXPORT}/tree/unrooted-tree"

      qiime tools export \
        --input-path "${QIIME_TREE}/rooted-tree.qza" \
        --output-path "${QIIME_EXPORT}/tree/rooted-tree"
    fi

    for qzv in "${QIIME_VISUAL}"/*.qzv; do
      [[ -e "${qzv}" ]] || continue
      qzv_name="$(basename "${qzv}" .qzv)"
      qiime tools export \
        --input-path "${qzv}" \
        --output-path "${QIIME_EXPORT}/visual/${qzv_name}"
    done
  fi

  log "${marker}: traitement termine"
  log "${marker}: manifest = ${MANIFEST}"
  log "${marker}: metadata = ${METADATA}"
  log "${marker}: resultats QIIME2 = ${QIIME_DIR}"
done

log "Pipeline complet termine avec succes pour : ${MARKERS[*]}"
