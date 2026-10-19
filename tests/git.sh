# Cases for status/scripts/git.sh
script=$checkout_dir/status/scripts/git.sh
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
git_in() { git -C "$1" -c user.name=t -c user.email=t@t "${@:2}"; }
show() { bash "$script" text "x$1" xI xD; }

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

# A directory name is untrusted input to the shell that runs the module's #()
hostile=$scratch/"a \$(touch $scratch/pwned) \"b'c \`touch $scratch/pwned2\`"
git init -q -b injected "$hostile"
env -u TMUX tmux -L oasis-gitbat-inject kill-server 2>/dev/null || true
env -u TMUX tmux -L oasis-gitbat-inject -f /dev/null new -d -s t -x 100 -y 10 -c "$hostile"
env -u TMUX tmux -L oasis-gitbat-inject source-file "$checkout_dir/oasis_tmux.conf"
env -u TMUX tmux -L oasis-gitbat-inject set -g status-interval 1
env -u TMUX tmux -L oasis-gitbat-inject set -g @oasis_git_icon 'I I'
env -u TMUX tmux -L oasis-gitbat-inject set -g @oasis_status_right git
env -u TMUX tmux -L oasis-gitbat-inject source-file "$checkout_dir/oasis_tmux.conf"
(env -u TMUX timeout 4 script -qfc "stty cols 100 rows 10; env -u TMUX tmux -L oasis-gitbat-inject attach -t t" "$scratch/term.log" >/dev/null 2>&1 || true)
env -u TMUX tmux -L oasis-gitbat-inject kill-server 2>/dev/null || true
drawn=$(sed 's/\x1b\[[0-9;?]*[a-zA-Z]//g' "$scratch/term.log")
case $drawn in *"I I injected"*) shown=yes ;; *) shown=no ;; esac
assert_equals "hostile directory name still shows its branch" yes "$shown"
assert_equals "hostile directory name ran nothing" "" "$(ls "$scratch" | grep '^pwned')"
