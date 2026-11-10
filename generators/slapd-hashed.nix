# An Argon2id hash of the first dependency, as an OpenLDAP userPassword value.
# OpenLDAP must load the argon2 module in cn=config for verification to work.
#
# The trailing newline from slappasswd is stripped.  Kept, it would be part of
# the base64 hash value, visible as a trailing Cg or Cg==, and every bind would
# fail silently.
{ lib }:
{
  decrypt,
  deps,
  pkgs,
  ...
}:
''
  ${pkgs.openldap}/bin/slappasswd \
    -o module-load=${pkgs.openldap}/lib/modules/argon2.so \
    -h '{ARGON2}' \
    -s "$(${decrypt} ${lib.escapeShellArg (builtins.elemAt deps 0).file})" \
    | tr -d '\n'
''
