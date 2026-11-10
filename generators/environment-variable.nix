# One KEY=value line for a systemd EnvironmentFile.  settings.field is the key
# and the first dependency is the value.  LoadCredential is the better path when
# a service can take it.  Some services only read the environment.
{ lib }:
{
  decrypt,
  deps,
  secret,
  ...
}:
''
  echo "${lib.escapeShellArg secret.settings.field}=$(${decrypt} ${
    lib.escapeShellArg (builtins.elemAt deps 0).file
  })"
''
