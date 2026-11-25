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

fake_home=$(mktemp -d)
trap 'rm -rf "$fake_home"' EXIT
mkdir "$fake_home/.kube"
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
assert_equals "auto matches the default" "K dev/payments" "$(show "$kube_fixtures/ns.yaml")"

big=$(mktemp)
{ cat "$kube_fixtures/ns.yaml"; for i in $(seq 1 6000); do printf '    certificate-authority-data: %0100d\n' "$i"; done; } > "$big"
start=$SECONDS
assert_equals "large file" "K dev/payments" "$(show "$big")"
assert_equals "large file is read in under 2 seconds" 1 "$(( SECONDS - start < 2 ))"
rm -f "$big"
