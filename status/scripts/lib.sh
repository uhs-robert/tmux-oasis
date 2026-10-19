# Shared helpers for the status scripts. Sourced, not run.
# Runs on macOS's bash 3.2: no associative arrays, mapfile, ${var,,} or \u escapes.

# Data roots, overridable so tests can point scripts at fixture trees
: "${OASIS_PROC_ROOT:=/proc}"
: "${OASIS_SYS_ROOT:=/sys}"
export OASIS_PROC_ROOT OASIS_SYS_ROOT

# Prints linux, macos or unsupported. Scripts print nothing on unsupported.
oasis_platform() {
  case "${OASIS_UNAME:-$(uname -s)}" in
    Linux)  printf 'linux' ;;
    Darwin) printf 'macos' ;;
    *)      printf 'unsupported' ;;
  esac
}

# Usage: oasis_option NAME [DEFAULT]. #() jobs inherit $TMUX, so this reaches the right server.
oasis_option() {
  local value
  value=$(tmux show -gqv "$1" 2>/dev/null)
  printf '%s' "${value:-${2:-}}"
}

# Usage: oasis_level VALUE WARN CRIT
# Prints ok, warn or crit; prints nothing if any argument is not a plain number.
# CRIT >= WARN means high is bad (value >= threshold trips it), CRIT < WARN means
# low is bad (value <= threshold); equal thresholds count as high is bad. Boundaries
# trip, and surrounding whitespace is ignored (macOS wc pads its numbers). awk does the comparing because
# bash has no decimals.
oasis_level() {
  awk -v value="${1:-}" -v warn="${2:-}" -v crit="${3:-}" '
    function trim(text) { gsub(/^[ \t]+|[ \t]+$/, "", text); return text }
    function number(text) { return text ~ /^-?[0-9]+(\.[0-9]+)?$/ }
    BEGIN {
      value = trim(value); warn = trim(warn); crit = trim(crit)
      if (!number(value) || !number(warn) || !number(crit)) exit
      value += 0; warn += 0; crit += 0
      if (crit >= warn) { is_crit = value >= crit; is_warn = value >= warn }
      else              { is_crit = value <= crit; is_warn = value <= warn }
      printf "%s", is_crit ? "crit" : is_warn ? "warn" : "ok"
    }'
}
