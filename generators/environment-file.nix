# A systemd EnvironmentFile built from environment-variable secrets.  Each
# dependency is one line of the file, so the dependencies are the fields.  A
# unit that reads the file lists the secret in restartTriggers.
{ lib }:
{ decrypt, deps, ... }:
lib.strings.concatStringsSep "; echo ; " (
  map (dep: "${decrypt} ${lib.escapeShellArg dep.file}") deps
)
