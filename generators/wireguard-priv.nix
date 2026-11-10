# A WireGuard private key, with the public key written beside the secret as
# .pub and added to git.
{ lib }:
{
  file,
  gitAdd,
  pkgs,
  ...
}:
let
  pubFile = lib.escapeShellArg (lib.removeSuffix ".age" file + ".pub");
in
''
  priv=$(${pkgs.wireguard-tools}/bin/wg genkey)
  ${pkgs.wireguard-tools}/bin/wg pubkey <<< "$priv" > ${pubFile}
  ${gitAdd} ${pubFile}
  echo -n "$priv"
''
