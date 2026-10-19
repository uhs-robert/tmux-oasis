#!/usr/bin/env bash
# Usage: git.sh text PATH
# Prints "@oasis_git_icon branch" plus @oasis_git_dirty_icon when tracked files have changes; the short
# SHA stands in for the branch on a detached HEAD. Prints nothing outside a repo.
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# Index refreshes would take the lock a foreground git in the same repo may need
export GIT_OPTIONAL_LOCKS=0

git_text() {
  local repo_path=$1 name dirty=""
  [ -d "$repo_path" ] || return 0
  name=$(git -C "$repo_path" symbolic-ref --short -q HEAD 2>/dev/null) ||
    name=$(git -C "$repo_path" rev-parse --short HEAD 2>/dev/null) || return 0
  # Untracked files are skipped: scanning them is what makes status slow on big trees
  [ -n "$(git -C "$repo_path" status --porcelain --untracked-files=no 2>/dev/null)" ] && dirty=$(oasis_option @oasis_git_dirty_icon)
  # tmux expands formats in #() output, so a branch like fix/#S-x would print the session name
  name=${name//#/##}
  printf '%s %s%s' "$(oasis_option @oasis_git_icon)" "$name" "$dirty"
}

case "${1:-}" in
  text) git_text "${2:-}" ;;
esac
