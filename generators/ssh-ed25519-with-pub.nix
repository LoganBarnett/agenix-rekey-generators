# An Ed25519 SSH private key, with the public key written beside the secret as
# <name>.pub and added to git.  agenix-rekey's own ssh-ed25519 generator drops
# the public key.
{ lib }:
{
  file,
  gitAdd,
  name,
  pkgs,
  ...
}:
''
  mkdir -p "$(dirname "${file}")"
  (exec 3>&1;
  ${pkgs.openssh}/bin/ssh-keygen \
    -q \
    -t ed25519 \
    -N "" \
    -C ${lib.escapeShellArg "${name}"} \
    -f ${name} \
    <<<y >/dev/null 2>&1;
    cp "${name}.pub" "$(dirname "${file}")"
    ${gitAdd} "$(dirname "${file}")/${name}.pub"
    echo copied public key ${name}.pub to "$(dirname "${file}")" 1>&2
    cat "${name}"
    rm "${name}"{,.pub}
  true)
''
