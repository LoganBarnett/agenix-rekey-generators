# A 4096 bit RSA private key in PEM form on one line.  Each newline becomes the
# two characters backslash and n, so the key sits inside a YAML double quoted
# string and comes out whole.  Authelia's OIDC issuer key is the consumer this
# was written for.
{ ... }:
{ pkgs, ... }:
''
  set -euo pipefail
  ${pkgs.openssl}/bin/openssl genpkey \
    -algorithm RSA \
    -pkeyopt rsa_keygen_bits:4096 \
    2>/dev/null \
    | ${pkgs.gnused}/bin/sed ':a;N;$!ba;s/\n/\\n/g'
''
