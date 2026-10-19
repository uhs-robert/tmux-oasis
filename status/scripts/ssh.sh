#!/usr/bin/env bash
# Usage: ssh.sh host TTY      the destination of the ssh running on TTY ("pts/3", "/dev/pts/3")
#        ssh.sh dest ARGS...  the destination in an ssh command line, ps output split into words
# Prints nothing when there is no ssh or no destination.
set -u
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# ssh options that consume the following word as their value
ssh_options_with_value=BbcDEeFIiJLlmOoPpQRSWw

# Usage: ssh_destination COMMAND [ARG ...]
ssh_destination() {
  shift
  local word cluster skip_next=false destination
  set -f
  while [ $# -gt 0 ]; do
    word=$1
    shift
    if $skip_next; then skip_next=false; continue; fi
    case $word in
      --) destination=${1-}; break ;;
      -?*)
        # Cluster such as -tt or -Nfp22: the first value-taking letter ends it, taking the rest or the next word
        cluster=${word#-}
        while [ -n "$cluster" ]; do
          case $ssh_options_with_value in
            *"${cluster:0:1}"*)
              [ -z "${cluster:1}" ] && skip_next=true
              break ;;
          esac
          cluster=${cluster:1}
        done ;;
      *) destination=$word; break ;;
    esac
  done
  [ -n "${destination-}" ] || return 0
  case $destination in
    ssh://*)
      destination=${destination#ssh://}
      destination=${destination%%/*}
      destination=${destination##*@}
      case $destination in
        \[*\]*) destination=${destination#\[}; destination=${destination%%\]*} ;;
        *) destination=${destination%%:*} ;;
      esac ;;
    *) destination=${destination##*@} ;;
  esac
  printf '%s' "$destination"
}

# Usage: ssh_host_on_tty TTY
ssh_host_on_tty() {
  local tty=${1#/dev/} line command_words
  [ -n "$tty" ] || return 0
  # Word-split on purpose: ps joins the arguments with spaces, quoting is lost
  while IFS= read -r line; do
    set -f
    command_words=($line)
    case ${command_words[0]-} in
      ssh|*/ssh) ssh_destination "${command_words[@]}"; return ;;
    esac
  done < <(ps -o args= -t "$tty" 2>/dev/null)
}

case ${1:-} in
  host) ssh_host_on_tty "${2:-}" ;;
  dest) shift; ssh_destination "$@" ;;
esac
