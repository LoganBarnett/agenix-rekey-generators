# A file with %name% placeholders filled from the dependencies, where name is
# each dependency's secret name.  settings.template is the text, or
# settings.templateFile is a path to it.  The result is itself a secret.  A unit
# that reads it lists the secret in restartTriggers.
#
# replace-secret reads the replacement from a file instead of an argument, so
# the decrypted dependency never appears in /proc/<pid>/cmdline.  It edits in
# place, hence staging the template in a temporary file and writing the result
# to stdout, which is what agenix-rekey captures.  It strips surrounding
# newlines from the secret, matching what command substitution would have done.
{ lib }:
{
  decrypt,
  deps,
  pkgs,
  secret,
  ...
}:
let
  template =
    secret.settings.template
      or (builtins.readFile secret.settings.templateFile);
in
''
  staged="$(${pkgs.coreutils}/bin/mktemp)"
  trap '${pkgs.coreutils}/bin/rm --force "$staged"' EXIT
  printf '%s' ${lib.escapeShellArg template} > "$staged"
  ${lib.strings.concatStringsSep "\n" (
    map (dep: ''
      ${pkgs.replace-secret}/bin/replace-secret \
        ${lib.escapeShellArg "%${dep.name}%"} \
        <(${decrypt} ${lib.escapeShellArg dep.file}) \
        "$staged"
    '') deps
  )}
  ${pkgs.coreutils}/bin/cat "$staged"
''
