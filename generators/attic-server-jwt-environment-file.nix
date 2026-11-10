# atticd's JWT signing secret as a systemd EnvironmentFile.  atticd and atticadm
# read ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64, the base64 of a PKCS#1 RSA
# private key in PEM form.  A unit that reads the file lists the secret in
# restartTriggers.
{ ... }:
{ pkgs, ... }:
''
  set -euo pipefail
  printf 'ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64=%s' \
    "$(${pkgs.openssl}/bin/openssl genrsa -traditional 4096 \
      | ${pkgs.coreutils}/bin/base64 --wrap 0)"
''
