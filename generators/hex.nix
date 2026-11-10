# Random hex.  settings.length is the number of bytes and defaults to 24, which
# is what agenix-rekey's own hex generator produces.
{ ... }:
{ pkgs, secret, ... }:
"${pkgs.openssl}/bin/openssl rand -hex ${
  toString (secret.settings.length or 24)
}"
