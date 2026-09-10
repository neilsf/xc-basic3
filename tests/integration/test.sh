#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

COMPILER="${REPO_ROOT}/bin/linux-gnu/xcbasic3"
declare -a GENERATED_FILES=()

cleanup() {
  local rc=$?

  for generated_file in "${GENERATED_FILES[@]:-}"; do
    rm -f "${generated_file}" || true
  done

  return "${rc}"
}
trap cleanup EXIT

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "ERROR: required command not found: $1" >&2
    exit 1
  fi
}

require_cmd grep

if [[ ! -x "${COMPILER}" ]]; then
  echo "ERROR: compiler not found or not executable: ${COMPILER}" >&2
  exit 1
fi

mapfile -t bas_files < <(find "${SCRIPT_DIR}" -type f -name '*.bas' -printf '%P\n' | sort)
if [[ ${#bas_files[@]} -eq 0 ]]; then
  echo "ERROR: no .bas files found under ${SCRIPT_DIR}" >&2
  exit 1
fi

if [[ $# -gt 0 ]]; then
  requested="$1"
  requested="${requested%/}"
  if [[ "${requested}" == "${SCRIPT_DIR}" ]]; then
    requested="."
  else
    requested="${requested#"${SCRIPT_DIR}/"}"
  fi
  if [[ "${requested}" == "${REPO_ROOT}/tests/integration" ]]; then
    requested="."
  else
    requested="${requested#"${REPO_ROOT}/tests/integration/"}"
  fi
  requested="${requested#tests/integration/}"
  requested="${requested#./}"

  declare -a filtered=()
  if [[ "${requested}" == "." || -d "${SCRIPT_DIR}/${requested}" ]]; then
    if [[ "${requested}" == "." ]]; then
      filtered=("${bas_files[@]}")
    else
      for bas in "${bas_files[@]}"; do
        if [[ "${bas}" == "${requested}/"* ]]; then
          filtered+=("${bas}")
        fi
      done
    fi
  else
    requested="${requested%.bas}.bas"
    for bas in "${bas_files[@]}"; do
      if [[ "${bas}" == "${requested}" || "$(basename "${bas}")" == "$(basename "${requested}")" ]]; then
        filtered+=("${bas}")
      fi
    done
  fi

  if [[ ${#filtered[@]} -eq 0 ]]; then
    echo "ERROR: no .bas file or directory matching '$1' found under ${SCRIPT_DIR}" >&2
    exit 1
  fi

  bas_files=("${filtered[@]}")
fi

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "${value}"
}

read_test_metadata() {
  local bas_path="$1"
  local -n compile_var="$2"
  local -n checks_var="$3"
  local -n negative_checks_var="$4"
  local line directive value

  compile_var=""
  checks_var=()
  negative_checks_var=()

  while IFS= read -r line || [[ -n "${line}" ]]; do
    line="${line%$'\r'}"
    if [[ "${line}" =~ ^[[:space:]]*$ ]]; then
      continue
    fi
    if [[ ! "${line}" =~ ^[[:space:]]*(\'|REM[[:space:]]) ]]; then
      break
    fi
    if [[ "${line}" =~ ^[[:space:]]*(\'|REM[[:space:]])[[:space:]]*([A-Z][A-Z_-]*):[[:space:]]*(.*)$ ]]; then
      directive="${BASH_REMATCH[2]}"
      value="$(trim "${BASH_REMATCH[3]}")"
      case "${directive}" in
        COMPILE)
          compile_var="${value}"
          ;;
        CHECK|ASM-CHECK|EXPECT)
          checks_var+=("${value}")
          ;;
        CHECK-NOT|ASM-CHECK-NOT|REJECT)
          negative_checks_var+=("${value}")
          ;;
      esac
    fi
  done < "${bas_path}"
}

run_compile() {
  local compile_cmd="$1"
  if [[ -n "${compile_cmd}" ]]; then
    eval "${compile_cmd}"
  else
    "${COMPILER}" --keep-imcode "${BAS}" "${PRG}"
  fi
}

total_tests=0
failed_tests=0

for bas in "${bas_files[@]}"; do
  bas_path="${SCRIPT_DIR}/${bas}"
  prg="${bas%.bas}.prg"
  asm="${bas%.bas}.asm"
  prg_path="${SCRIPT_DIR}/${prg}"
  asm_path="${SCRIPT_DIR}/${asm}"
  compile_log="$(mktemp)"
  total_tests=$((total_tests + 1))

  mkdir -p "$(dirname "${prg_path}")"
  GENERATED_FILES+=("${prg_path}" "${asm_path}")

  read_test_metadata "${bas_path}" compile_cmd regex_checks negative_regex_checks
  if [[ ${#regex_checks[@]} -eq 0 && ${#negative_regex_checks[@]} -eq 0 ]]; then
    echo "FAIL ${bas}: no CHECK or CHECK-NOT rules found in leading comments" >&2
    failed_tests=$((failed_tests + 1))
    rm -f "${compile_log}"
    continue
  fi

  BAS="${bas}"
  BAS_PATH="${bas_path}"
  PRG="${prg}"
  PRG_PATH="${prg_path}"
  ASM="${asm}"
  ASM_PATH="${asm_path}"
  TEST_DIR="${SCRIPT_DIR}"

  printf 'compiling %s... ' "${bas}"
  if (
    cd "${SCRIPT_DIR}"
    run_compile "${compile_cmd}"
  ) >"${compile_log}" 2>&1; then
    echo "OK"
  else
    echo "FAILED"
    cat "${compile_log}" >&2
    rm -f "${compile_log}"
    failed_tests=$((failed_tests + 1))
    continue
  fi
  rm -f "${compile_log}"

  if [[ ! -f "${asm_path}" ]]; then
    echo "FAIL ${bas}: expected intermediate assembly file was not created: ${asm_path}" >&2
    failed_tests=$((failed_tests + 1))
    continue
  fi

  mismatch_count=0
  for regex in "${regex_checks[@]}"; do
    if ! grep -Eq -- "${regex}" "${asm_path}"; then
      echo "${bas}: missing assembly match for /${regex}/" >&2
      mismatch_count=$((mismatch_count + 1))
    fi
  done
  for regex in "${negative_regex_checks[@]}"; do
    if grep -Eq -- "${regex}" "${asm_path}"; then
      echo "${bas}: unexpected assembly match for /${regex}/" >&2
      mismatch_count=$((mismatch_count + 1))
    fi
  done

  if (( mismatch_count == 0 )); then
    echo "PASS ${bas}"
  else
    echo "FAIL ${bas}: ${mismatch_count} regex rule failure(s)" >&2
    failed_tests=$((failed_tests + 1))
  fi
done

echo "Summary: ${total_tests} test(s), ${failed_tests} failure(s)."
if (( failed_tests > 0 )); then
  exit 1
fi