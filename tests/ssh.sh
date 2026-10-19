# Cases for status/scripts/ssh.sh
ssh_script=$checkout_dir/status/scripts/ssh.sh
destination() { bash "$ssh_script" dest "$@"; }

assert_equals "plain host" myhost "$(destination ssh myhost)"
assert_equals "user@host" myhost "$(destination ssh alice@myhost)"
assert_equals "port option" myhost "$(destination ssh -p 22 myhost)"
assert_equals "attached port" myhost "$(destination ssh -p22 myhost)"
assert_equals "jump host" myhost "$(destination ssh -J jump myhost)"
assert_equals "option with key=value and a remote command" myhost "$(destination ssh -o Foo=bar myhost ls -la /tmp)"
assert_equals "doubled flag" myhost "$(destination ssh -tt myhost)"
assert_equals "flag cluster ending in a value option" myhost "$(destination ssh -Nfp 22 myhost)"
assert_equals "flag cluster with attached value" myhost "$(destination ssh -Nfp22 myhost)"
assert_equals "identity file and user" myhost "$(destination ssh -i ~/.ssh/key bob@myhost)"
assert_equals "after --" myhost "$(destination ssh -v -- myhost)"
assert_equals "value that looks like a host" myhost "$(destination ssh -l root myhost)"
assert_equals "URI with user and port" myhost "$(destination ssh ssh://alice@myhost:2222)"
assert_equals "URI with port" myhost "$(destination ssh ssh://myhost:2222)"
assert_equals "URI with IPv6" ::1 "$(destination ssh ssh://alice@[::1]:22)"
assert_equals "full path to ssh" myhost "$(destination /usr/bin/ssh -4 myhost)"
assert_equals "host with dots" db.example.com "$(destination ssh alice@db.example.com)"
assert_equals "no destination" "" "$(destination ssh -v)"
assert_equals "no arguments" "" "$(destination ssh)"
assert_equals "empty tty" "" "$(bash "$ssh_script" host "")"
