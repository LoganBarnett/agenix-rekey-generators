# Random bytes as URL-safe base64 per RFC 4648 with no line break, for opaque
# client secrets.  settings.length is the number of bytes before encoding and
# defaults to 60.
{ ... }:
{ pkgs, secret, ... }:
''
  ${pkgs.openssl}/bin/openssl rand ${
    toString (secret.settings.length or 60)
  } | ${pkgs.coreutils}/bin/basenc --base64url --wrap=0
''
