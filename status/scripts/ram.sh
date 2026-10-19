#!/usr/bin/env bash
# Usage: ram.sh display|state
# Used memory as a percent. Linux counts what isn't MemAvailable (so reclaimable cache
# is free); macOS counts active, wired and compressed pages.
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

case "$(oasis_platform)" in
  linux)
    used=$(awk '
      /^MemTotal:/     { total = $2 }
      /^MemAvailable:/ { available = $2 }
      END { if (total > 0 && available != "") printf "%d", (total - available) * 100 / total + 0.5 }
    ' "$OASIS_PROC_ROOT/meminfo" 2>/dev/null)
    ;;
  macos)
    # Page size is 16384 on Apple Silicon and 4096 on Intel, so it comes from vm_stat's header
    used=$(vm_stat 2>/dev/null | awk -v total="$(sysctl -n hw.memsize 2>/dev/null)" '
      /page size of/ { sub(/.*page size of /, ""); page = $1 + 0 }
      /^Pages active:/                 { pages += $3 }
      /^Pages wired down:/             { pages += $4 }
      /^Pages occupied by compressor:/ { pages += $5 }
      END { if (total > 0 && page > 0) printf "%d", pages * page * 100 / total + 0.5 }
    ')
    ;;
  *) exit 0 ;;
esac

oasis_report "${1:-}" "$used" "%" "$(oasis_option @oasis_ram_warn 80)" "$(oasis_option @oasis_ram_crit 90)"
