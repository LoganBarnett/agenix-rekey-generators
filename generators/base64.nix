# Random bytes as standard base64 with padding and no line break.
# settings.length is the number of bytes before encoding.  It defaults to 32,
# which is what agenix-rekey's own base64 generator produces.
{ ... }:
{ pkgs, secret, ... }:
''
  ${pkgs.openssl}/bin/openssl rand --base64 ${
    toString (secret.settings.length or 32)
  } | tr -d '\n'
''
