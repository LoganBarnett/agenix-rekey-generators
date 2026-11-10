# A leaf key signed by a tls-ca-root.  The certificate is written beside the key
# as <name without .key>.crt and added to git, along with the root's .srl file
# of used serial numbers.  settings.fqdn names the leaf.
# settings.root-certificate is the root's age.secrets entry, and that entry is
# also the one dependency.
{ lib }:
let
  tls = import ../lib/tls.nix { inherit lib; };
  inherit (lib) isAttrs isString;
  inherit (lib.trivial) throwIfNot;
in
{
  decrypt,
  deps,
  file,
  gitAdd,
  name,
  pkgs,
  secret,
  ...
}:
let
  settings = secret.settings or null;
  rootDep = builtins.elemAt deps 0;
in
throwIfNot (isAttrs settings) "Secret '${name}' must have a `settings` attrset."
  throwIfNot
  (isString (settings.fqdn or null))
  "Secret '${name}' is missing a `fqdn` string."
  ''
    set -euo pipefail
    ${decrypt} "${rootDep.file}" > ca.key
    cert_path="$(dirname "${rootDep.file}")/${rootDep.name}.crt"
    out_file="$(dirname "${file}")/$(basename ${name} '.key').crt"
    ${pkgs.openssl}/bin/openssl req \
       -new \
       -newkey rsa:4096 \
       -sha256 \
       -nodes \
       -keyout signing.key \
       -out signing.crt \
       -subj "/CN=${settings.fqdn}${
         tls.subjectString settings.root-certificate.settings.tls.subject
       }" \
       -addext "subjectAltName = DNS:${settings.fqdn}"
    echo "subjectAltName = DNS:${settings.fqdn}" > san.cnf
    ${pkgs.openssl}/bin/openssl x509 \
       -req \
       -in signing.crt \
       -CA $cert_path \
       -CAkey ca.key \
       -CAcreateserial \
       -out $out_file \
       -days 356 \
       -extfile san.cnf
    ${pkgs.openssl}/bin/openssl verify \
      -CAfile $cert_path \
      $out_file \
      1>&2
    ${gitAdd} "$out_file" "''${cert_path%.crt}.srl"
    cat signing.key
    rm ca.key
    rm san.cnf
    rm signing.{crt,key}
  ''
