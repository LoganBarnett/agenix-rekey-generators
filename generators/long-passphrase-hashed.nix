# A SHA-512 crypt hash of the first dependency, for consumers that take an
# /etc/shadow style hash.  Any plaintext secret works as the dependency.
{ lib }:
{
  decrypt,
  deps,
  pkgs,
  ...
}:
''
  ${decrypt} ${lib.escapeShellArg (builtins.elemAt deps 0).file} | \
     ${pkgs.openssl}/bin/openssl passwd -6 -stdin
''
