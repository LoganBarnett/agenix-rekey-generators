# An Ed25519 DKIM private key in PKCS#8 PEM form.  The bare base64 public key
# is written beside the secret as <name>.pub and added to git.  It is the p=
# value of the DNS TXT record "v=DKIM1; k=ed25519; p=<contents of .pub>".
{ ... }:
{
  file,
  gitAdd,
  name,
  pkgs,
  ...
}:
''
  set -euo pipefail
  pub_file="$(dirname "${file}")/${name}.pub"
  ${pkgs.openssl}/bin/openssl genpkey -algorithm Ed25519 -out priv.pem
  ${pkgs.openssl}/bin/openssl pkey -in priv.pem -pubout \
    | grep -v '^-----' | tr -d '\n' > "$pub_file"
  ${gitAdd} "$pub_file"
  cat priv.pem
  rm priv.pem
''
