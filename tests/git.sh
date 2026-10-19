# Cases for status/scripts/git.sh
script=$checkout_dir/status/scripts/git.sh
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
git_in() { git -C "$1" -c user.name=t -c user.email=t@t "${@:2}"; }
show() { bash "$script" text "$1" I D; }

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
