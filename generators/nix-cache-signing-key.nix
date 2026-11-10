# A Nix binary cache signing key in the form nix key generate-secret emits,
# <name>:<base64>.  The public half is written beside the secret as .pub and
# added to git, so a consumer reads it at evaluation time for
# trusted-public-keys.  settings.keyName names the key.
{ lib }:
{
  file,
  gitAdd,
  name,
  pkgs,
  secret,
  ...
}:
let
  keyName =
    secret.settings.keyName or (throw
      "age.secrets.${
        name
      }: generator nix-cache-signing-key requires settings.keyName"
    );
  nix = "${pkgs.nix}/bin/nix --extra-experimental-features nix-command";
  pubFile = lib.escapeShellArg (lib.removeSuffix ".age" file + ".pub");
in
''
  set -euo pipefail
  ${pkgs.coreutils}/bin/mkdir --parents "$(${pkgs.coreutils}/bin/dirname ${
    pubFile
  })"
  secret="$(${nix} key generate-secret --key-name ${
    lib.escapeShellArg keyName
  })"
  printf '%s' "$secret" \
    | ${nix} key convert-secret-to-public \
    | ${pkgs.coreutils}/bin/tr --delete '\n' > ${pubFile}
  ${gitAdd} ${pubFile}
  printf '%s' "$secret"
''
