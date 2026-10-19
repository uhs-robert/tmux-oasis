# Cases for status/scripts/git.sh
script=$checkout_dir/status/scripts/git.sh
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
git_in() { git -C "$1" -c user.name=t -c user.email=t@t "${@:2}"; }
# Scripts read their icons with `tmux show`, which would reach the owner's server from here
tmux() { case $3 in @oasis_git_icon) printf I ;; @oasis_git_dirty_icon) printf D ;; esac; }
export -f tmux
show() { bash "$script" text "$1"; }

repo=$scratch/repo
git init -q -b main "$repo"
echo one > "$repo/file"
git_in "$repo" add file
git_in "$repo" commit -q -m first
assert_equals "clean repo" "I main" "$(show "$repo")"

echo new > "$repo/untracked"
assert_equals "untracked files are not dirty" "I main" "$(show "$repo")"

echo two > "$repo/file"
assert_equals "modified tracked file is dirty" "I mainD" "$(show "$repo")"
git_in "$repo" checkout -q file

mkdir "$repo/sub"
assert_equals "subdirectory of a repo" "I main" "$(show "$repo/sub")"

git_in "$repo" checkout -q --detach
assert_equals "detached HEAD shows the short sha" "I $(git_in "$repo" rev-parse --short HEAD)" "$(show "$repo")"

mkdir "$scratch/plain"
assert_equals "not a repo" "" "$(show "$scratch/plain")"
assert_equals "missing directory" "" "$(show "$scratch/missing")"
assert_equals "empty path" "" "$(show "")"

spaced="$scratch/with space"
git init -q -b feature "$spaced"
assert_equals "path with a space, unborn branch" "I feature" "$(show "$spaced")"

unset -f tmux # the servers below and their #() jobs must reach real tmux

# Usage: draw_git_bar DIR -- the text of a status bar showing only the git module, drawn in DIR
draw_git_bar() {
  env -u TMUX tmux -L oasis-gitbat-draw kill-server 2>/dev/null || true
  env -u TMUX tmux -L oasis-gitbat-draw -f /dev/null new -d -s t -x 100 -y 10 -c "$1"
  env -u TMUX tmux -L oasis-gitbat-draw set -g status-interval 1
  env -u TMUX tmux -L oasis-gitbat-draw set -g @oasis_git_icon 'I I'
  env -u TMUX tmux -L oasis-gitbat-draw set -g @oasis_status_right git
  env -u TMUX tmux -L oasis-gitbat-draw source-file "$checkout_dir/oasis_tmux.conf"
  (env -u TMUX timeout 4 script -qfc "stty cols 100 rows 10; env -u TMUX tmux -L oasis-gitbat-draw attach -t t" "$scratch/term.log" >/dev/null 2>&1 || true)
  env -u TMUX tmux -L oasis-gitbat-draw kill-server 2>/dev/null || true
  sed 's/\x1b\[[0-9;?]*[a-zA-Z]//g' "$scratch/term.log"
}

# A directory name is untrusted input to the shell that runs the module's #()
hostile=$scratch/"a \$(touch $scratch/pwned) \"b'c \`touch $scratch/pwned2\`"
git init -q -b injected "$hostile"
case $(draw_git_bar "$hostile") in *"I I injected"*) shown=yes ;; *) shown=no ;; esac
assert_equals "hostile directory name still shows its branch" yes "$shown"
assert_equals "hostile directory name ran nothing" "" "$(ls "$scratch" | grep '^pwned')"

# tmux would expand #S in a branch name to the session name
git init -q -b 'fix/#S-x' "$scratch/hash_branch"
case $(draw_git_bar "$scratch/hash_branch") in *"I I fix/#S-x"*) shown=yes ;; *) shown=no ;; esac
assert_equals "branch name with a format code is shown literally" yes "$shown"
