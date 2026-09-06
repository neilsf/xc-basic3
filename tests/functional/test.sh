#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

COMPILER="${REPO_ROOT}/bin/linux-gnu/xcbasic3"
VICE_LOG="${SCRIPT_DIR}/.vice_functional.log"
DUMP_DIR="${SCRIPT_DIR}/.vice_dumps"
MONITOR_HOST="127.0.0.1"
MONITOR_PORT="6510"
declare -a GENERATED_PRGS=()

cleanup() {
  local rc=$?

  if [[ -n "${VICE_PID:-}" ]] && kill -0 "${VICE_PID}" >/dev/null 2>&1; then
    kill "${VICE_PID}" >/dev/null 2>&1 || true
    wait "${VICE_PID}" >/dev/null 2>&1 || true
  fi

  for prg in "${GENERATED_PRGS[@]:-}"; do
    rm -f "${prg}" || true
  done

  find "${SCRIPT_DIR}" -type f \( -name '.vice_functional.log' -o -name '.bytes_vice.log' -o -name '.bytes_monitor_dump.txt' \) -delete || true
  find "${SCRIPT_DIR}" -type d -name '.vice_dumps' -prune -exec rm -rf {} + || true

  return "${rc}"
}
trap cleanup EXIT

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "ERROR: required command not found: $1" >&2
    exit 1
  fi
}

require_cmd x64sc
require_cmd nc
require_cmd stdbuf
require_cmd awk
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
  # Allow the argument to be given as an absolute/relative path, a path
  # relative to SCRIPT_DIR, with or without the .bas extension. If a
  # directory is given, run all tests under that directory.
  requested="${requested%/}"
  if [[ "${requested}" == "${SCRIPT_DIR}" ]]; then
    requested="."
  else
    requested="${requested#"${SCRIPT_DIR}/"}"
  fi
  if [[ "${requested}" == "${REPO_ROOT}/tests/functional" ]]; then
    requested="."
  else
    requested="${requested#"${REPO_ROOT}/tests/functional/"}"
  fi
  requested="${requested#tests/functional/}"
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

for bas in "${bas_files[@]}"; do
  data_file="${SCRIPT_DIR}/${bas%.bas}.data"
  if [[ ! -f "${data_file}" ]]; then
    echo "ERROR: missing golden data file: ${data_file}" >&2
    exit 1
  fi
done

find "${SCRIPT_DIR}" -type f \( -name '.vice_functional.log' -o -name '.bytes_vice.log' -o -name '.bytes_monitor_dump.txt' \) -delete
find "${SCRIPT_DIR}" -type d -name '.vice_dumps' -prune -exec rm -rf {} +
mkdir -p "${DUMP_DIR}"

extract_hex_bytes() {
  local source_file="$1"
  awk '
    {
      line = $0
      if (match(line, />[A-Za-z]:[0-9A-Fa-f]{4}[[:space:]]+/)) {
        line = substr(line, RSTART + RLENGTH)
      } else if (match(line, /^[[:space:]]*[0-9A-Fa-f]{4}:[[:space:]]*/)) {
        line = substr(line, RLENGTH + 1)
      }
      n = split(line, a, /[[:space:]]+/)
      for (i = 1; i <= n; i++) {
        if (a[i] ~ /^[0-9A-Fa-f]{2}$/) {
          print toupper(a[i])
        }
      }
    }
  ' "${source_file}"
}

DEFAULT_MONITOR_CMD="m c000 c0ff"

# A test can override the monitor dump command by putting a
# ' MONITOR: <command>
# comment anywhere in its .bas file, e.g. ' MONITOR: m 1000 10ff
get_monitor_command() {
  local bas_path="$1"
  local cmd
  cmd=$(grep -m1 -oP "^[[:space:]]*'[[:space:]]*MONITOR:[[:space:]]*\K.*" "${bas_path}" || true)
  cmd="${cmd%$'\r'}"
  cmd="${cmd%"${cmd##*[![:space:]]}"}"
  if [[ -z "${cmd}" ]]; then
    cmd="${DEFAULT_MONITOR_CMD}"
  fi
  printf '%s' "${cmd}"
}

# Extracts the start address (hex, no prefix) that a 'm <start> <end>' monitor command dumps from.
monitor_command_start_addr() {
  local cmd="$1"
  echo "${cmd}" | grep -oP '(?<=^m )[0-9A-Fa-f]+' | head -1
}

wait_for_autostart_done() {
  local previous_count="$1"
  local done_count
  for _ in $(seq 1 300); do
    done_count=$(grep -c 'Autostart: Done\.' "${VICE_LOG}" || true)
    if (( done_count > previous_count )); then
      return 0
    fi
    if ! kill -0 "${VICE_PID}" >/dev/null 2>&1; then
      return 1
    fi
    sleep 0.1
  done
  return 1
}

send_monitor_command() {
  local cmd="$1"
  printf '%s\n' "${cmd}" | nc -w 2 "${MONITOR_HOST}" "${MONITOR_PORT}" >/dev/null 2>&1 || true
}

read_monitor_dump() {
  local out_var="$1"
  local monitor_cmd="$2"
  local start_addr="$3"
  local dump_text=""
  for _ in $(seq 1 30); do
    dump_text="$(printf '%s\n' "${monitor_cmd}" | nc -w 2 "${MONITOR_HOST}" "${MONITOR_PORT}" || true)"
    if printf '%s\n' "${dump_text}" | grep -qiE ">[A-Za-z]:${start_addr}"; then
      printf -v "${out_var}" '%s' "${dump_text}"
      return 0
    fi
    sleep 0.1
  done
  return 1
}

for bas in "${bas_files[@]}"; do
  prg="${bas%.bas}.prg"
  GENERATED_PRGS+=("${SCRIPT_DIR}/${prg}")
  printf 'compiling %s... ' "${bas}"
  compile_log="$(mktemp)"
  if (
    cd "${SCRIPT_DIR}"
    "${COMPILER}" "${bas}" "${prg}"
  ) >"${compile_log}" 2>&1; then
    echo "OK"
    rm -f "${compile_log}"
  else
    echo "FAILED"
    cat "${compile_log}" >&2
    rm -f "${compile_log}"
    exit 1
  fi
done

echo "Launching VICE headless..."
first_prg="${bas_files[0]%.bas}.prg"
(
  cd "${SCRIPT_DIR}"
  stdbuf -oL -eL x64sc --console -remotemonitor "${first_prg}"
) >"${VICE_LOG}" 2>&1 &
VICE_PID=$!

if ! wait_for_autostart_done 0; then
  echo "ERROR: timed out waiting for initial 'Autostart: Done.'" >&2
  echo "--- VICE log ---" >&2
  cat "${VICE_LOG}" >&2
  exit 1
fi

echo "Running monitor comparisons..."
total_tests=0
failed_tests=0

for idx in "${!bas_files[@]}"; do
  bas="${bas_files[$idx]}"
  bas_path="${SCRIPT_DIR}/${bas}"
  prg="${SCRIPT_DIR}/${bas%.bas}.prg"
  data_file="${SCRIPT_DIR}/${bas%.bas}.data"
  dump_file="${DUMP_DIR}/${bas%.bas}.dump.txt"
  total_tests=$((total_tests + 1))

  mkdir -p "$(dirname "${dump_file}")"

  monitor_cmd=$(get_monitor_command "${bas_path}")
  start_addr=$(monitor_command_start_addr "${monitor_cmd}")
  if [[ -z "${start_addr}" ]]; then
    echo "FAIL ${bas}: could not determine start address from monitor command '${monitor_cmd}'" >&2
    failed_tests=$((failed_tests + 1))
    continue
  fi
  start_addr_dec=$((16#${start_addr}))

  if (( idx > 0 )); then
    done_before=$(grep -c 'Autostart: Done\.' "${VICE_LOG}" || true)
    send_monitor_command "autostart \"${prg}\""
    if ! wait_for_autostart_done "${done_before}"; then
      echo "FAIL ${bas}: autostart did not complete" >&2
      failed_tests=$((failed_tests + 1))
      continue
    fi
  fi

  sleep 1

  if ! read_monitor_dump monitor_output "${monitor_cmd}" "${start_addr}"; then
    echo "FAIL ${bas}: unable to read monitor dump" >&2
    failed_tests=$((failed_tests + 1))
    continue
  fi

  printf '%s\n' "${monitor_output}" > "${dump_file}"

  mapfile -t actual_bytes < <(extract_hex_bytes "${dump_file}")
  mapfile -t expected_bytes < <(extract_hex_bytes "${data_file}")

  if [[ ${#actual_bytes[@]} -ne ${#expected_bytes[@]} ]]; then
    echo "FAIL ${bas}: parsed ${#actual_bytes[@]} bytes from monitor, expected ${#expected_bytes[@]} bytes from ${data_file}" >&2
    failed_tests=$((failed_tests + 1))
    continue
  fi

  mismatch_count=0
  for i in "${!expected_bytes[@]}"; do
    if [[ "${actual_bytes[$i]}" != "${expected_bytes[$i]}" ]]; then
      addr=$(printf '%04X' $((start_addr_dec + i)))
      echo "${bas}: mismatch at ${addr}, expected ${expected_bytes[$i]}, got ${actual_bytes[$i]}" >&2
      mismatch_count=$((mismatch_count + 1))
    fi
  done

  if (( mismatch_count == 0 )); then
    echo "PASS ${bas}"
  else
    echo "FAIL ${bas}: ${mismatch_count} byte mismatches" >&2
    failed_tests=$((failed_tests + 1))
  fi
done

echo "Summary: ${total_tests} test(s), ${failed_tests} failure(s)."
if (( failed_tests > 0 )); then
  exit 1
fi
