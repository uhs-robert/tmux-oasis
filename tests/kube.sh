# Cases for status/scripts/kube.sh
script=$checkout_dir/status/scripts/kube.sh
kube_fixtures=$fixtures_dir/kube
# Scripts read their options with `tmux show`, which would reach the owner's server from here
tmux() { case $3 in @oasis_kube_icon) printf K ;; @oasis_kube_namespace) printf '%s' "${test_namespace_mode:-}" ;; esac; }
export -f tmux
show() { KUBECONFIG=$1 HOME=/nonexistent bash "$script" text; }

assert_equals "context and non-default namespace" "K dev/payments" "$(show "$kube_fixtures/ns.yaml")"
assert_equals "context without namespace" "K plain" "$(show "$kube_fixtures/no_namespace.yaml")"
assert_equals "quoted values, explicit default namespace" "K dev" "$(show "$kube_fixtures/quoted_default.yaml")"
assert_equals "name key before context key, no trailing newline" "K rev/kube-system" "$(show "$kube_fixtures/name_first.yaml")"
assert_equals "CRLF line endings" "K dev/payments" "$(show "$kube_fixtures/crlf.yaml")"
assert_equals "context missing from the list" "K gone" "$(show "$kube_fixtures/unknown_context.yaml")"
assert_equals "# in a name is doubled" "K team##1/payments" "$(show "$kube_fixtures/hash.yaml")"

assert_equals "empty current-context" "" "$(show "$kube_fixtures/empty_context.yaml")"
assert_equals "no current-context" "" "$(show "$kube_fixtures/no_current.yaml")"
assert_equals "empty file" "" "$(show "$kube_fixtures/empty.yaml")"
assert_equals "missing file" "" "$(show "$kube_fixtures/missing.yaml")"
assert_equals "directory instead of file" "" "$(show "$kube_fixtures")"

assert_equals "two files: context from the first, namespace from the second" "K second/late" \
  "$(show "$kube_fixtures/first_file.yaml:$kube_fixtures/second_file.yaml")"
assert_equals "missing file first in the list" "K dev/payments" \
  "$(show "$kube_fixtures/missing.yaml:$kube_fixtures/ns.yaml")"
assert_equals "first file that sets current-context wins" "K plain" \
  "$(show "$kube_fixtures/no_namespace.yaml:$kube_fixtures/ns.yaml")"

scratch=$(mktemp -d)
fake_home=$scratch/home
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$fake_home/.kube"
cp "$kube_fixtures/ns.yaml" "$fake_home/.kube/config"
assert_equals "default path without KUBECONFIG" "K dev/payments" "$(env -u KUBECONFIG HOME="$fake_home" bash "$script" text)"
assert_equals "no config at all" "" "$(env -u KUBECONFIG HOME=/nonexistent bash "$script" text)"

export test_namespace_mode=always
assert_equals "always shows a non-default namespace" "K dev/payments" "$(show "$kube_fixtures/ns.yaml")"
assert_equals "always shows default when unset" "K plain/default" "$(show "$kube_fixtures/no_namespace.yaml")"
assert_equals "always shows an explicit default" "K dev/default" "$(show "$kube_fixtures/quoted_default.yaml")"
export test_namespace_mode=never
assert_equals "never hides the namespace" "K dev" "$(show "$kube_fixtures/ns.yaml")"
export test_namespace_mode=auto
assert_equals "auto shows a non-default namespace" "K dev/payments" "$(show "$kube_fixtures/ns.yaml")"
assert_equals "auto hides an explicit default" "K dev" "$(show "$kube_fixtures/quoted_default.yaml")"

assert_equals "indented list, name after context" "K dev/payments" "$(sed 's/^current-context: .*/current-context: dev/' "$kube_fixtures/indented.yaml" > "$scratch/i.yaml"; show "$scratch/i.yaml")"
assert_equals "indented list, name first, nested lists ignored" "K other/elsewhere" "$(show "$kube_fixtures/indented.yaml")"
assert_equals "column-0 comment in the list and trailing comments" "K dev/payments" "$(show "$kube_fixtures/comments.yaml")"

# Many contexts, as in a kubeconfig that collects every cluster of a team. The best of five runs keeps a
# loaded machine from failing the test; a fork per line costs several times the limit.
many=$scratch/many.yaml
{ printf 'contexts:\n'
  for i in $(seq 1 150); do
    printf -- '- context:\n    cluster: c%s\n    namespace: ns%s\n    user: u%s\n  name: ctx%s\n' "$i" "$i" "$i" "$i"
  done
  printf 'current-context: ctx150\n'; } > "$many"
assert_equals "150 contexts" "K ctx150/ns150" "$(show "$many")"
TIMEFORMAT=%3R
best_ms=99999
for _ in 1 2 3 4 5; do
  seconds_text=$( { time show "$many" >/dev/null; } 2>&1 )
  run_ms=$(( 10#${seconds_text/./} ))
  [ "$run_ms" -lt "$best_ms" ] && best_ms=$run_ms
done
assert_equals "150 contexts are read in under 150 ms (best was $best_ms ms)" 1 "$(( best_ms < 150 ))"

# The module and its _when must run the same command, so tmux runs one job and the gate matches the text
conf_server=oasis-test-kubeconf
trap 'rm -rf "$fake_home" "$scratch"; env -u TMUX tmux -L $conf_server kill-server 2>/dev/null || true' EXIT
env -u TMUX tmux -L $conf_server -f /dev/null new -d -s t -x 80 -y 5
env -u TMUX tmux -L $conf_server set -g @oasis_scripts_dir /scripts
env -u TMUX tmux -L $conf_server source-file "$checkout_dir/status/modules/kube.conf"
module_command=$(env -u TMUX tmux -L $conf_server show -gv @oasis_module_kube)
when_command=$(env -u TMUX tmux -L $conf_server show -gv @oasis_module_kube_when)
assert_equals "_when gates on the module's own command" "#{!=:$module_command,}" "$when_command"
assert_equals "namespace mode defaults to auto" auto "$(env -u TMUX tmux -L $conf_server show -gv @oasis_kube_namespace)"
env -u TMUX tmux -L $conf_server kill-server
