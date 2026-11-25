#!/usr/bin/env bash
# Usage: kube.sh text
# Prints "@oasis_kube_icon context/namespace" from the kubeconfig files, never running kubectl.
# Prints nothing without a readable config that sets a current context.
# $KUBECONFIG is a colon list: like kubectl, the first file that sets current-context wins, and
# so does the first file that defines the context entry. #() jobs see the tmux server's environment.
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# Strips the key, surrounding whitespace (CR included) and one pair of quotes from a "key: value" line
yaml_value() {
  local value=${1#*:}
  value=${value#"${value%%[![:space:]]*}"}
  value=${value%"${value##*[![:space:]]}"}
  case $value in
    \"*\") value=${value#\"}; value=${value%\"} ;;
    \'*\') value=${value#\'}; value=${value%\'} ;;
  esac
  printf '%s' "$value"
}

# Usage: scan_file FILE WANTED_CONTEXT
# Sets file_current from the top-level current-context key. With WANTED_CONTEXT, sets
# file_namespace and file_has_context from the matching entry of the contexts list.
scan_file() {
  local line section="" entry_name="" entry_namespace="" in_entry=0
  file_current="" file_namespace="" file_has_context=0
  while IFS= read -r line || [ -n "$line" ]; do
    case $line in
      current-context:*) file_current=$(yaml_value "$line"); section=other; continue ;;
      contexts:*) section=contexts; continue ;;
      [![:space:]-]*) section=other; continue ;;
    esac
    [ "$section" = contexts ] || continue
    case $line in
      "- "*|"-")
        in_entry=1; entry_name=""; entry_namespace=""
        line=${line#-}; line="  ${line# }" ;;
    esac
    [ "$in_entry" = 1 ] || continue
    case $line in
      "  name:"*) entry_name=$(yaml_value "$line") ;;
      *[[:space:]]namespace:*) entry_namespace=$(yaml_value "$line") ;;
    esac
    if [ -n "$2" ] && [ "$entry_name" = "$2" ]; then
      file_has_context=1; file_namespace=$entry_namespace
    fi
  done < "$1"
}

kube_text() {
  local files file current="" namespace="" mode
  IFS=: read -r -a files <<< "${KUBECONFIG:-$HOME/.kube/config}"
  for file in "${files[@]}"; do
    [ -r "$file" ] && [ -f "$file" ] || continue
    scan_file "$file" ""
    if [ -n "$file_current" ]; then current=$file_current; break; fi
  done
  [ -n "$current" ] || return 0
  for file in "${files[@]}"; do
    [ -r "$file" ] && [ -f "$file" ] || continue
    scan_file "$file" "$current"
    if [ "$file_has_context" = 1 ]; then namespace=$file_namespace; break; fi
  done
  mode=$(oasis_option @oasis_kube_namespace auto)
  case $mode in
    never) namespace="" ;;
    always) namespace=${namespace:-default} ;;
    *) [ "$namespace" = default ] && namespace="" ;;
  esac
  current=${current:+$current${namespace:+/$namespace}}
  # tmux expands formats in #() output, so each # is doubled
  printf '%s %s' "$(oasis_option @oasis_kube_icon)" "${current//#/##}"
}

case "${1:-}" in
  text) kube_text ;;
esac
