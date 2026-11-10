# A self-signed root certificate.  The key is the secret and the certificate is
# written beside it as <name>.crt and added to git.  settings.tls carries the
# domain, the validity in days, and the subject.  README.org names the keys.
{ lib }:
let
  tls = import ../lib/tls.nix { inherit lib; };
  inherit (lib) isAttrs;
  inherit (lib.trivial) throwIfNot;
in
{
  file,
  gitAdd,
  name,
  pkgs,
  secret,
  ...
}:
let
  settings = secret.settings or null;
in
throwIfNot (isAttrs settings) "Secret '${name}' must have a `settings` attrset."
  tls.validateSettings
  name
  (settings.tls or null)
  ''
    set -euo pipefail
    crt_file="$(dirname "${file}")/${name}.crt"
    # keyUsage is required on a CA certificate by RFC 5280 section 4.2.1.3.
    # Most TLS stacks ignored that for years.  Python 3.13 with urllib3 2.5
    # does not.  keyCertSign permits signing certificates and cRLSign permits
    # signing revocation lists.  pathlen:0 keeps this root from minting an
    # intermediate CA.
    #
    # nameConstraints, RFC 5280 section 4.2.1.10, limits the DNS names this CA
    # can sign for.  Without it a stolen CA key mints a valid certificate for
    # any domain, and every client trusting this root accepts it.  The
    # constraint matches the name and any name with labels added to its left,
    # so permitted;DNS:example covers example and host.example.  It is critical
    # so a client that does not understand it fails closed.  Only DNS is
    # constrained.  IP and email SANs stay open, so revisit this if a leaf ever
    # uses one.
    ${pkgs.openssl}/bin/openssl req \
       -new \
       -newkey rsa:4096 \
       -keyout root.key \
       -x509 \
       -nodes \
       -out "$crt_file" \
       -subj "/CN=${settings.tls.domain}${
         tls.subjectString settings.tls.subject
       }" \
       -days "${toString settings.tls.validity}" \
       -addext "basicConstraints = critical, CA:TRUE, pathlen:0" \
       -addext "keyUsage = critical, keyCertSign, cRLSign" \
       -addext "nameConstraints = critical, permitted;DNS:${
         settings.tls.domain
       }"
    ${gitAdd} "$crt_file"
    cat root.key
    rm root.key
  ''
