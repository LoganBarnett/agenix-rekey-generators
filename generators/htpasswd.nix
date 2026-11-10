# An htpasswd entry for settings.username from each dependency, hashed with
# bcrypt.
{ lib }:
{
  decrypt,
  deps,
  pkgs,
  secret,
  ...
}:
# htpasswd flags:
#   -n: output to stdout.
#   -i: read password from stdin.
#   -B: bcrypt hashing.
#   -C: bcrypt cost factor.
# htpasswd outputs "username:hash\n" to stdout.  printf avoids the heredoc
# adding a second trailing newline.
lib.strings.concatMapStrings (
  { file, ... }:
  "printf '%s\\n' \"$(${decrypt} ${lib.escapeShellArg file} "
  + "| ${pkgs.apacheHttpd}/bin/htpasswd -niBC 10 "
  + "${lib.escapeShellArg secret.settings.username})\"; "
) deps
