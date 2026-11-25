#!/usr/bin/env bash
# Usage: kube.sh text
# Prints "@oasis_kube_icon context/namespace" from the kubeconfig files, never running kubectl.
# Prints nothing without a readable config that sets a current context.
# $KUBECONFIG is a colon list: like kubectl, the first file that sets current-context wins, and
# so does the first file that defines the context entry. #() jobs see the tmux server's environment.
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# Usage: yaml_value LINE. Sets yaml_result to the value of a "key: value" line: surrounding
# whitespace (CR included), one pair of quotes and a trailing comment are dropped.
# It sets a variable instead of printing because a $() per line made big files slow.
yaml_value() {
  local value=${1#*:}
  value=${value#"${value%%[![:space:]]*}"}
  case $value in
    \"*) value=${value#\"}; value=${value%%\"*} ;;
    \'*) value=${value#\'}; value=${value%%\'*} ;;
    *)
      value=${value%%[[:space:]]#*}
      value=${value%"${value##*[![:space:]]}"} ;;
  esac
  yaml_result=$value
}

# Usage: scan_file FILE WANTED_CONTEXT
# Sets file_current from the top-level current-context key. With WANTED_CONTEXT, also sets
# file_namespace and file_has_context from the matching entry of the contexts list.
# Without it, the contexts list is skipped and the scan stops at current-context.
scan_file() {
  local line section="" entry_name="" entry_namespace="" in_entry=0 seq_indent=-1 indent rest key_prefix="" namespace_indent=0
  file_current="" file_namespace="" file_has_context=0
  while IFS= read -r line || [ -n "$line" ]; do
    case $line in
      \#*) continue ;;
      current-context:*)
        yaml_value "$line"; file_current=$yaml_result; section=other
        [ -n "$2" ] || return 0
        continue ;;
      contexts:*) section=contexts; seq_indent=-1; in_entry=0; continue ;;
      [![:space:]-]*) section=other; continue ;;
    esac
    [ "$section" = contexts ] && [ -n "$2" ] || continue
    indent=${line%%[![:space:]]*}
    rest=${line#"$indent"}
    case $rest in \#*) continue ;; esac
    # An entry starts at a dash; later dashes deeper than the first belong to the entry's own lists
    case $rest in
      "- "*|"-")
        [ "$seq_indent" -ge 0 ] || seq_indent=${#indent}
        if [ "${#indent}" -eq "$seq_indent" ]; then
          in_entry=1; entry_name=""; entry_namespace=""; namespace_indent=-1
          key_prefix="$indent  "
          rest=${rest#-}; rest=${rest# }
          line="$key_prefix$rest"
        fi ;;
    esac
    [ "$in_entry" = 1 ] || continue
    case $line in
      "${key_prefix}name:"*) yaml_value "$line"; entry_name=$yaml_result ;;
      # The shallowest namespace is the context's own, not one inside an extension
      *[[:space:]]namespace:*)
        if [ "$namespace_indent" -lt 0 ] || [ "${#indent}" -le "$namespace_indent" ]; then
          yaml_value "$line"; entry_namespace=$yaml_result; namespace_indent=${#indent}
        fi ;;
    esac
    if [ "$entry_name" = "$2" ]; then
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
